# frozen_string_literal: true

module BrValidators
  # Placa de veículo, nos dois modelos que circulam:
  #
  # - Antiga (cinza): 3 letras e 4 números, escrita "ABC-1234".
  # - Mercosul: LLLNLNN (letra, letra, letra, número, letra, número, número),
  #   escrita "ABC1D23".
  #
  # Para converter a placa antiga, troca-se só o quinto caractere (o segundo
  # número) por uma letra: 0 vira A, 1 vira B... 9 vira J. Ex.: ABC-1234 → ABC1C34.
  # As letras de A a J nessa posição existem justamente para essa conversão, e os
  # dois formatos valem para buscar o mesmo veículo.
  #
  # Fonte: Resolução CONTRAN nº 780/2019, Anexo I (item 1.2) e Anexo II.
  module Placa
    ANTIGA = /\A[A-Z]{3}\d{4}\z/
    MERCOSUL = /\A[A-Z]{3}\d[A-Z]\d{2}\z/

    # Pontos, hífens e espaços.
    MASK = /[.\p{Pd}[:space:]]/

    # Tira a máscara e passa as letras para maiúsculas: "abc-1234" vira "ABC1234".
    # O upcase(:ascii) está explicado no CNPJ.
    def self.strip(value)
      BrValidators.texto(value).gsub(MASK, "").upcase(:ascii)
    end

    # :antiga, :mercosul ou nil se a placa for inválida.
    def self.type(value)
      placa = strip(value)
      return :antiga if placa.match?(ANTIGA)
      return :mercosul if placa.match?(MERCOSUL)

      nil
    end

    def self.valid?(value)
      !type(value).nil?
    end

    # Devolve "ABC-1234" (antiga) ou "ABC1D23" (Mercosul), ou nil se for inválida.
    def self.format(value)
      placa = strip(value)
      case type(placa)
      when :antiga then "#{placa[0, 3]}-#{placa[3, 4]}"
      when :mercosul then placa
      end
    end

    # A placa no modelo Mercosul: converte a antiga e devolve a Mercosul como está.
    #   mercosul("ABC-1234") # => "ABC1C34"
    def self.mercosul(value)
      placa = strip(value)
      case type(placa)
      when :antiga then placa[0, 4] + ("A".ord + placa[4].to_i).chr + placa[5, 2]
      when :mercosul then placa
      end
    end

    # A placa no modelo antigo: desfaz a conversão (só para letras de A a J na
    # quinta posição) e devolve a antiga como está. Placa Mercosul emitida já no
    # modelo novo, com outra letra, não tem placa antiga: devolve nil.
    #   antiga("ABC1C34") # => "ABC1234"
    def self.antiga(value)
      placa = strip(value)
      return placa if type(placa) == :antiga
      return nil unless type(placa) == :mercosul && placa[4].between?("A", "J")

      placa[0, 4] + (placa[4].ord - "A".ord).to_s + placa[5, 2]
    end
  end
end
