# frozen_string_literal: true

module BrValidators
  # Linha digitável de boleto. Aceita os dois tipos:
  #
  # Cobrança (bancos), 47 dígitos em 5 campos:
  #   AAABC.CCCCX DDDDD.DDDDDY EEEEE.EEEEEZ K UUUUVVVVVVVVVV
  #   - campos 1, 2 e 3 terminam com um dígito verificador de módulo 10;
  #   - K é o dígito verificador geral do código de barras (módulo 11);
  #   - UUUU é o fator de vencimento e V o valor.
  #   Fonte: especificação de boleto do Banco do Brasil, que segue o padrão FEBRABAN.
  #   https://www.bb.com.br/docs/pub/emp/empl/dwn/Doc5175Bloqueto.pdf
  #
  # Arrecadação (contas de consumo, tributos), 48 dígitos, sempre começa com 8:
  #   4 blocos de 11 dígitos, cada um seguido do seu dígito verificador.
  #   O 3º dígito diz o módulo: 6 ou 7 usam módulo 10; 8 ou 9 usam módulo 11.
  #   O 4º dígito é o verificador geral do código de barras.
  #   Fonte: "Layout padrão de arrecadação" da FEBRABAN, versão 7 (2023). O manual
  #   diz que o dígito de cada bloco usa o mesmo módulo do verificador geral.
  #   https://cmsarquivos.febraban.org.br/Arquivos/documentos/PDF/Layout%20-%20C%C3%B3digo%20de%20Barras%20-%20Vers%C3%A3o%207%20-%2001_03_2023_mn.pdf
  module Boleto
    # Pontos, espaços e hífens que aparecem na linha impressa. A linha copiada do
    # PDF do boleto ou do site do banco costuma vir com espaço não separável, que
    # [:space:] também pega.
    MASK = /[.\p{Pd}[:space:]]/

    def self.strip(value)
      BrValidators.texto(value).gsub(MASK, "")
    end

    # :cobranca, :arrecadacao ou nil se a linha for inválida.
    def self.type(value)
      type_stripped(strip(value))
    end

    def self.valid?(value)
      !type(value).nil?
    end

    # Devolve a linha com a máscara de cada tipo, ou nil se for inválida:
    #   cobrança:    "00190.00009 02345.678904 12345.678176 1 10000000012345"
    #   arrecadação: "82670000001-9 00000000000-0 00000000000-0 00000000000-0"
    def self.format(value)
      line = strip(value)
      case type_stripped(line)
      when :cobranca then format_cobranca(line)
      when :arrecadacao then line.scan(/\d{12}/).map { |block| "#{block[0, 11]}-#{block[11]}" }.join(" ")
      end
    end

    # A regra, com a linha já sem máscara.
    def self.type_stripped(line)
      return :cobranca if line.match?(/\A\d{47}\z/) && valid_cobranca?(line)

      :arrecadacao if line.match?(/\A8\d{47}\z/) && valid_arrecadacao?(line)
    end

    def self.format_cobranca(line)
      "#{line[0, 5]}.#{line[5, 5]} #{line[10, 5]}.#{line[15, 6]} " \
        "#{line[21, 5]}.#{line[26, 6]} #{line[32]} #{line[33, 14]}"
    end

    def self.valid_cobranca?(line)
      fields = [line[0, 10], line[10, 11], line[21, 11]]
      return false unless fields.all? { |field| check_digit_ok?(field, method(:mod10)) }

      barcode = cobranca_barcode(line)
      barcode[4] == mod11_cobranca(without(barcode, 4)).to_s
    end

    # Remonta o código de barras (44 dígitos) a partir da linha digitável:
    # banco e moeda, DV geral, fator e valor, e o "campo livre" dos campos 1 a 3.
    def self.cobranca_barcode(line)
      line[0, 4] + line[32] + line[33, 14] + line[4, 5] + line[10, 10] + line[21, 10]
    end

    def self.valid_arrecadacao?(line)
      check = arrecadacao_check(line[2])
      return false unless check

      blocks = line.scan(/\d{12}/)
      return false unless blocks.all? { |block| check_digit_ok?(block, check) }

      barcode = blocks.map { |block| block[0, 11] }.join
      barcode[3] == check.call(without(barcode, 3)).to_s
    end

    # O 3º dígito da arrecadação diz qual módulo usar. Outros valores são inválidos.
    def self.arrecadacao_check(value_id)
      case value_id
      when "6", "7" then method(:mod10)
      when "8", "9" then method(:mod11_arrecadacao)
      end
    end

    # O último dígito do trecho é o verificador dos anteriores?
    def self.check_digit_ok?(chunk, check)
      chunk[-1] == check.call(chunk[0..-2]).to_s
    end

    # O texto sem o caractere da posição indicada (onde fica o DV geral).
    def self.without(text, index)
      text[0, index] + text[(index + 1)..]
    end

    # Pesos 2, 1, 2, 1... da direita para a esquerda; produtos com dois algarismos
    # entram somados (12 vira 1 + 2). O dígito é o que falta para a próxima dezena.
    # getbyte - 48 é o valor do dígito (explicado em digitos.rb).
    def self.mod10(digits)
      last = digits.size - 1
      sum = (0..last).sum do |index|
        product = (digits.getbyte(last - index) - 48) * (index.even? ? 2 : 1)
        (product / 10) + (product % 10)
      end
      (10 - (sum % 10)) % 10
    end

    # Na cobrança, a soma é a do módulo 11 com pesos de 2 a 9 (Digitos, em
    # digitos.rb), mas quando a conta dá 0, 10 ou 11 o dígito vira 1 (nunca é 0).
    def self.mod11_cobranca(digits)
      digit = 11 - (Digitos.soma_pesos_2_a_9(digits) % 11)
      [0, 10, 11].include?(digit) ? 1 : digit
    end

    # Na arrecadação, é o módulo 11 comum: resto 0 ou 1 vira dígito 0.
    def self.mod11_arrecadacao(digits)
      Digitos.modulo11(digits)
    end

    private_class_method :type_stripped, :format_cobranca, :valid_cobranca?, :cobranca_barcode,
                         :valid_arrecadacao?, :arrecadacao_check, :check_digit_ok?, :without, :mod10,
                         :mod11_cobranca, :mod11_arrecadacao
  end
end
