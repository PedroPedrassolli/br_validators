# frozen_string_literal: true

module BrValidators
  # CPF: 11 dígitos, sendo os dois últimos verificadores.
  #
  # Cada dígito verificador é calculado com módulo 11 sobre os dígitos anteriores:
  # o primeiro usa pesos de 10 a 2 nos 9 primeiros dígitos; o segundo usa pesos de
  # 11 a 2 nos 10 primeiros (os 9 + o primeiro verificador). Se o resto da divisão
  # por 11 for 0 ou 1, o dígito é 0; senão, é 11 menos o resto.
  module CPF
    # Caracteres de máscara que aceitamos na entrada: ponto, traços e espaços.
    # Ao copiar um número de um PDF, do Word ou de um site, o hífen pode virar
    # meia-risca (–) ou hífen sem quebra, e o espaço pode virar o não separável:
    # \p{Pd} pega qualquer traço e [:space:] qualquer espaço. Os outros módulos
    # seguem a mesma ideia.
    MASK = /[.\p{Pd}[:space:]]/

    # Tira a máscara: "123.456.789-09" vira "12345678909".
    # Não remove letras nem outros símbolos, para que valid? possa recusá-los.
    # BrValidators.texto (texto.rb) converte para UTF-8 e troca bytes inválidos
    # por "�", que nunca passa na validação.
    def self.strip(value)
      BrValidators.texto(value).gsub(MASK, "")
    end

    def self.valid?(value)
      valid_stripped?(strip(value))
    end

    # Devolve "123.456.789-09", ou nil se o CPF for inválido
    # (formatar um número errado esconderia o erro de quem chamou).
    def self.format(value)
      digits = strip(value)
      return nil unless valid_stripped?(digits)

      "#{digits[0, 3]}.#{digits[3, 3]}.#{digits[6, 3]}-#{digits[9, 2]}"
    end

    # A regra, com o CPF já sem máscara.
    def self.valid_stripped?(digits)
      return false unless digits.match?(/\A\d{11}\z/)

      # 111.111.111-11, 222.222.222-22... passam na conta, mas não são CPFs reais.
      return false if digits.squeeze.size == 1

      digits[9, 2] == check_digits(digits[0, 9])
    end

    def self.check_digits(base)
      first = check_digit(base)
      second = check_digit("#{base}#{first}")
      "#{first}#{second}"
    end

    # Pesos decrescentes até 2, começando por (tamanho + 1): 10..2 para 9 dígitos,
    # 11..2 para 10 dígitos. getbyte devolve o código ASCII do dígito; menos 48 dá
    # o valor dele ("0" é 48), sem criar uma string por dígito.
    def self.check_digit(digits)
      first_weight = digits.size + 1
      sum = (0...digits.size).sum { |index| (digits.getbyte(index) - 48) * (first_weight - index) }
      rest = sum % 11
      (rest < 2 ? 0 : 11 - rest).to_s
    end

    private_class_method :valid_stripped?, :check_digits, :check_digit
  end
end
