# frozen_string_literal: true

module BrValidators
  # Título de eleitor: 12 dígitos.
  #   - 8 primeiros: número sequencial;
  #   - 9º e 10º: código da UF onde foi emitido (01 a 28; 28 é o exterior, "ZZ");
  #   - 11º e 12º: dígitos verificadores.
  #
  # 1º dígito: soma dos 8 primeiros com pesos de 2 a 9, da esquerda para a
  # direita; o dígito é o resto da divisão por 11.
  # 2º dígito: soma dos 2 dígitos da UF e do 1º dígito, com pesos 7, 8 e 9;
  # também é o resto da divisão por 11.
  # Nos dois casos, resto 10 vira 0. Em títulos de São Paulo (01) e Minas Gerais
  # (02), resto 0 vira 1.
  #
  # Alguns títulos antigos de SP e MG têm 13 dígitos (9 no número sequencial).
  # Eles não são aceitos aqui: a regra pública só cobre os de 12.
  #
  # Fonte: o TSE não publica o cálculo. A regra é a usada pelos sistemas e
  # explicada pela OBMEP em "A Matemática nos Documentos: Título de Eleitor".
  # https://clubes.obmep.org.br/blog/a-matematica-nos-documentos-titulo-de-eleitor/
  module TituloEleitor
    UFS = {
      "01" => "SP", "02" => "MG", "03" => "RJ", "04" => "RS", "05" => "BA", "06" => "PR",
      "07" => "CE", "08" => "PE", "09" => "SC", "10" => "GO", "11" => "MA", "12" => "PB",
      "13" => "PA", "14" => "ES", "15" => "PI", "16" => "RN", "17" => "AL", "18" => "MT",
      "19" => "MS", "20" => "DF", "21" => "SE", "22" => "AM", "23" => "RO", "24" => "AC",
      "25" => "AP", "26" => "RR", "27" => "TO", "28" => "ZZ"
    }.freeze

    # O título impresso mostra o número em grupos separados por espaço.
    MASK = %r{[./\p{Pd}[:space:]]}

    def self.strip(value)
      BrValidators.texto(value).gsub(MASK, "")
    end

    def self.valid?(value)
      titulo = strip(value)
      return false unless titulo.match?(/\A\d{12}\z/)

      uf = titulo[8, 2]
      return false unless UFS.key?(uf)

      first = check_digit(weighted_sum(titulo[0, 8], 2..9), uf)
      second = check_digit(weighted_sum("#{uf}#{first}", 7..9), uf)
      titulo[10, 2] == "#{first}#{second}"
    end

    # Devolve "1023 8501 0671", ou nil se o título for inválido.
    def self.format(value)
      return nil unless valid?(value)

      titulo = strip(value)
      "#{titulo[0, 4]} #{titulo[4, 4]} #{titulo[8, 4]}"
    end

    # A sigla da UF onde o título foi emitido ("SP", "ZZ" para o exterior), ou nil.
    def self.uf(value)
      valid?(value) ? UFS[strip(value)[8, 2]] : nil
    end

    def self.weighted_sum(digits, weights)
      digits.chars.zip(weights.to_a).sum { |digit, weight| digit.to_i * weight }
    end

    # codigo_uf: "01" (SP) e "02" (MG) têm a regra especial do resto 0.
    def self.check_digit(sum, codigo_uf)
      rest = sum % 11
      return 1 if rest.zero? && %w[01 02].include?(codigo_uf)

      rest == 10 ? 0 : rest
    end

    private_class_method :weighted_sum, :check_digit
  end
end
