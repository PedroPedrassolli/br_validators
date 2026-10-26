# frozen_string_literal: true

module BrValidators
  # CEP (Código de Endereçamento Postal): 8 dígitos, escritos como 00000-000.
  #
  # Os 5 primeiros dígitos dizem a região, a sub-região, o setor, o subsetor e o
  # divisor de subsetor; os 3 últimos (o sufixo) identificam a rua, a localidade
  # ou a unidade dos Correios.
  #
  # O CEP não tem dígito verificador: aqui só dá para conferir o formato. Para
  # saber se o CEP existe (e qual é o endereço), use a consulta online da gem
  # (BrValidators::Consulta.cep).
  #
  # Fonte: "Tudo sobre CEP", dos Correios.
  # https://www.correios.com.br/enviar/precisa-de-ajuda/imagens/tudo-sobre-cep
  module CEP
    # Pontos, hífens e espaços (inclusive os Unicode, como o não separável).
    MASK = /[.\-[:space:]]/

    # O scrub está explicado no CPF: texto corrompido vira inválido, sem erro.
    def self.strip(value)
      value.to_s.scrub.gsub(MASK, "")
    end

    # 8 dígitos. "00000-000" é o CEP que sistemas usam como "não informado";
    # nenhuma região dos Correios começa com 00000.
    def self.valid?(value)
      cep = strip(value)
      cep.match?(/\A\d{8}\z/) && cep != "00000000"
    end

    # Devolve "01001-000", ou nil se o CEP for inválido.
    def self.format(value)
      return nil unless valid?(value)

      cep = strip(value)
      "#{cep[0, 5]}-#{cep[5, 3]}"
    end
  end
end
