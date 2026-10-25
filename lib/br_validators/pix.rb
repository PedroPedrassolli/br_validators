# frozen_string_literal: true

module BrValidators
  # Chave Pix: diz se a chave está no formato que o DICT (o diretório de chaves
  # do Banco Central) aceita e qual é o tipo dela.
  #
  # Tipos e formatos, como o DICT guarda as chaves (sem máscara):
  # - :cpf   -> 11 dígitos, com os dígitos verificadores corretos
  # - :cnpj  -> 14 caracteres, numérico ou alfanumérico, com os verificadores corretos
  # - :phone -> "+", código do país e número, só dígitos (ex.: "+5511987654321")
  # - :email -> em minúsculas, com no máximo 77 caracteres
  # - :evp   -> chave aleatória, um UUID em minúsculas
  #
  # Fontes: especificação da API do DICT e Manual Operacional do DICT (v8.5),
  # que passou a aceitar o CNPJ alfanumérico.
  # https://github.com/bacen/pix-dict-api
  # https://www.bcb.gov.br/content/estabilidadefinanceira/pix/Regulamento_Pix/X_ManualOperacionaldoDICT.pdf
  module Pix
    MAX_LENGTH = 77

    PHONE = /\A\+[1-9][0-9]\d{1,14}\z/
    EVP = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/

    # Mesma expressão da especificação do DICT, quebrada em linhas (o "x" no
    # final faz o Ruby ignorar as quebras). O "\#" precisa da barra: sem ela,
    # o Ruby leria "#$&" como uma variável e sumiria com esses caracteres.
    EMAIL = %r{
      \A[a-z0-9.!\#$&'*+/=?^_`{|}~-]+
      @[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?
      (?:\.[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?)*\z
    }x

    # Cada tipo e a verificação dele, na ordem em que são testados.
    CHECKS = {
      cpf: ->(key) { key.match?(/\A\d{11}\z/) && CPF.valid?(key) },
      cnpj: ->(key) { key.match?(/\A[0-9A-Z]{12}\d{2}\z/) && CNPJ.valid?(key) },
      phone: ->(key) { key.match?(PHONE) },
      email: ->(key) { key.match?(EMAIL) },
      evp: ->(key) { key.match?(EVP) }
    }.freeze

    # Devolve :cpf, :cnpj, :phone, :email ou :evp, ou nil se a chave for inválida.
    # Só os espaços nas pontas são ignorados: o resto precisa estar exatamente
    # como o DICT guarda (sem máscara, e-mail e chave aleatória em minúsculas).
    def self.type(value)
      key = value.to_s.strip
      return nil if key.size > MAX_LENGTH

      found = CHECKS.find { |_type, check| check.call(key) }
      found&.first
    end

    def self.valid?(value)
      !type(value).nil?
    end
  end
end
