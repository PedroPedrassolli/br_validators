# frozen_string_literal: true

module BrValidators
  # Número de processo judicial na numeração única do CNJ:
  #
  #   NNNNNNN-DD.AAAA.J.TR.OOOO  (20 dígitos)
  #   NNNNNNN  número sequencial do processo no ano
  #   DD       dígito verificador
  #   AAAA     ano em que o processo começou
  #   J        segmento do Judiciário (1 a 9, ver SEGMENTOS)
  #   TR       tribunal dentro do segmento
  #   OOOO     unidade de origem
  #
  # O dígito verificador usa módulo 97 (norma ISO 7064). Para conferir, junta-se
  # NNNNNNN AAAA J TR OOOO e coloca-se o DD no fim; o número de 20 dígitos que sai
  # dividido por 97 precisa deixar resto 1.
  #
  # Fonte: Resolução CNJ nº 65/2008, art. 1º e Anexo VIII.
  # https://atos.cnj.jus.br/files/resolucao_comp_65_16122008_26032019140041.pdf
  module ProcessoCNJ
    SEGMENTOS = {
      "1" => "Supremo Tribunal Federal",
      "2" => "Conselho Nacional de Justiça",
      "3" => "Superior Tribunal de Justiça",
      "4" => "Justiça Federal",
      "5" => "Justiça do Trabalho",
      "6" => "Justiça Eleitoral",
      "7" => "Justiça Militar da União",
      "8" => "Justiça dos Estados e do Distrito Federal",
      "9" => "Justiça Militar Estadual"
    }.freeze

    # Pontos, hífens e espaços.
    MASK = /[.\p{Pd}[:space:]]/

    def self.strip(value)
      BrValidators.texto(value).gsub(MASK, "")
    end

    def self.valid?(value)
      valid_stripped?(strip(value))
    end

    # Devolve "0000123-45.2024.8.26.0100", ou nil se o número for inválido.
    def self.format(value)
      numero = strip(value)
      return nil unless valid_stripped?(numero)

      "#{numero[0, 7]}-#{numero[7, 2]}.#{numero[9, 4]}.#{numero[13]}.#{numero[14, 2]}.#{numero[16, 4]}"
    end

    # O nome do segmento do Judiciário ("Justiça do Trabalho"), ou nil se o número
    # for inválido.
    def self.segmento(value)
      numero = strip(value)
      valid_stripped?(numero) ? SEGMENTOS[numero[13]] : nil
    end

    # A regra, com o número já sem máscara.
    def self.valid_stripped?(numero)
      return false unless numero.match?(/\A\d{20}\z/)
      return false unless SEGMENTOS.key?(numero[13])

      # NNNNNNN + AAAA J TR OOOO + DD
      (numero[0, 7] + numero[9, 11] + numero[7, 2]).to_i % 97 == 1
    end

    private_class_method :valid_stripped?
  end
end
