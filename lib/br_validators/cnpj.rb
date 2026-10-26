# frozen_string_literal: true

module BrValidators
  # CNPJ: 14 caracteres. Os 12 primeiros podem ser números ou letras maiúsculas
  # (formato alfanumérico, usado pela Receita Federal a partir de julho de 2026);
  # os 2 últimos são sempre dígitos verificadores. Os CNPJs só com números
  # continuam válidos e seguem a mesma conta.
  #
  # Cada caractere vale o código ASCII dele menos 48: "0" vale 0, "9" vale 9,
  # "A" vale 17, "Z" vale 42. Os dígitos verificadores usam módulo 11 com pesos
  # de 2 a 9, da direita para a esquerda (voltando ao 2 depois do 9).
  # Se o resto for 0 ou 1, o dígito é 0; senão, é 11 menos o resto.
  #
  # Fonte: manual do dígito verificador do CNPJ, da Receita Federal.
  # https://www.gov.br/receitafederal/pt-br/centrais-de-conteudo/publicacoes/documentos-tecnicos/cnpj/manual-dv-cnpj.pdf
  module CNPJ
    # Caracteres de máscara aceitos na entrada: ponto, barra, hífen e espaços
    # (inclusive os espaços Unicode, como o não separável).
    MASK = %r{[./\p{Pd}[:space:]]}

    # 12 caracteres alfanuméricos e 2 dígitos no final.
    PATTERN = /\A[0-9A-Z]{12}\d{2}\z/

    # Tira a máscara e passa as letras para maiúsculas:
    # "12.abc.345/01de-35" vira "12ABC34501DE35".
    # A Receita só usa maiúsculas, mas é comum alguém digitar em minúsculas.
    #
    # upcase(:ascii) mexe só nas letras de a a z. O upcase normal segue o Unicode e
    # transforma "ı" (i sem ponto) em "I" e "ß" em "SS", o que faria um texto
    # errado passar como CNPJ válido.
    def self.strip(value)
      BrValidators.texto(value).gsub(MASK, "").upcase(:ascii)
    end

    def self.valid?(value)
      cnpj = strip(value)
      return false unless cnpj.match?(PATTERN)

      # 00.000.000/0000-00 e parecidos passam na conta, mas não existem.
      return false if cnpj.squeeze.size == 1

      cnpj[12, 2] == check_digits(cnpj[0, 12])
    end

    # Devolve "12.ABC.345/01DE-35", ou nil se o CNPJ for inválido.
    def self.format(value)
      return nil unless valid?(value)

      cnpj = strip(value)
      "#{cnpj[0, 2]}.#{cnpj[2, 3]}.#{cnpj[5, 3]}/#{cnpj[8, 4]}-#{cnpj[12, 2]}"
    end

    def self.check_digits(base)
      first = check_digit(base)
      second = check_digit("#{base}#{first}")
      "#{first}#{second}"
    end

    def self.check_digit(chars)
      # Pesos 2, 3, ..., 9, 2, 3... a partir do último caractere.
      sum = chars.reverse.chars.each_with_index.sum do |char, index|
        (char.ord - 48) * ((index % 8) + 2)
      end
      rest = sum % 11
      (rest < 2 ? 0 : 11 - rest).to_s
    end

    private_class_method :check_digits, :check_digit
  end
end
