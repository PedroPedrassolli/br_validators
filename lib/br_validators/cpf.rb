# frozen_string_literal: true

module BrValidators
  # CPF: 11 dígitos, sendo os dois últimos verificadores.
  #
  # Cada dígito verificador é calculado com módulo 11 sobre os dígitos anteriores:
  # o primeiro usa pesos de 10 a 2 nos 9 primeiros dígitos; o segundo usa pesos de
  # 11 a 2 nos 10 primeiros (os 9 + o primeiro verificador). Se o resto da divisão
  # por 11 for 0 ou 1, o dígito é 0; senão, é 11 menos o resto.
  module CPF
    # Caracteres de máscara que aceitamos na entrada: ponto, hífen e espaços.
    MASK = /[.\-\s]/

    # Tira a máscara: "123.456.789-09" vira "12345678909".
    # Não remove letras nem outros símbolos, para que valid? possa recusá-los.
    def self.strip(value)
      value.to_s.gsub(MASK, "")
    end

    def self.valid?(value)
      digits = strip(value)
      return false unless digits.match?(/\A\d{11}\z/)

      # 111.111.111-11, 222.222.222-22... passam na conta, mas não são CPFs reais.
      return false if digits.squeeze.size == 1

      digits[9, 2] == check_digits(digits[0, 9])
    end

    # Devolve "123.456.789-09", ou nil se o CPF for inválido
    # (formatar um número errado esconderia o erro de quem chamou).
    def self.format(value)
      return nil unless valid?(value)

      digits = strip(value)
      "#{digits[0, 3]}.#{digits[3, 3]}.#{digits[6, 3]}-#{digits[9, 2]}"
    end

    def self.check_digits(base)
      first = check_digit(base)
      second = check_digit("#{base}#{first}")
      "#{first}#{second}"
    end

    # Pesos decrescentes até 2, começando por (tamanho + 1): 10..2 para 9 dígitos,
    # 11..2 para 10 dígitos.
    def self.check_digit(digits)
      weights = (2..(digits.size + 1)).to_a.reverse
      sum = digits.chars.zip(weights).sum { |digit, weight| digit.to_i * weight }
      rest = sum % 11
      (rest < 2 ? 0 : 11 - rest).to_s
    end

    private_class_method :check_digits, :check_digit
  end
end
