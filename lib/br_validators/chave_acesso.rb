# frozen_string_literal: true

module BrValidators
  # Chave de acesso dos documentos fiscais eletrônicos (NF-e, NFC-e, CT-e, MDF-e):
  # 44 caracteres.
  #
  #   cUF (2)    código IBGE da UF do emitente
  #   AAMM (4)   ano e mês de emissão
  #   CNPJ (14)  CNPJ do emitente (ou CPF com zeros à esquerda)
  #   mod (2)    modelo do documento: 55 NF-e, 65 NFC-e, 57 CT-e, 58 MDF-e...
  #   serie (3), nNF (9), tpEmis (1), cNF (8) e o dígito verificador (1)
  #
  # Com o CNPJ alfanumérico, os 12 primeiros caracteres do CNPJ podem ter letras;
  # todo o resto continua só com números. Além do dígito verificador, conferimos
  # que o cUF é o código IBGE de uma UF e que o mês vai de 01 a 12 (sem isso, uma
  # chave só de zeros passaria).
  #
  # O dígito verificador usa módulo 11 com pesos de 2 a 9, da direita para a
  # esquerda, sobre os 43 primeiros caracteres. Cada caractere vale o código ASCII
  # dele menos 48 (como no CNPJ alfanumérico: "0" vale 0, "A" vale 17). Se o resto
  # for 0 ou 1, o dígito é 0; senão, é 11 menos o resto.
  #
  # Fontes: Manual de Orientação do Contribuinte da NF-e e Nota Técnica Conjunta
  # 2025.001 (CNPJ alfanumérico nos documentos fiscais eletrônicos), publicados no
  # Portal da NF-e. https://www.nfe.fazenda.gov.br/portal/
  # Códigos das UFs: tabela do IBGE. https://www.ibge.gov.br/explica/codigos-dos-municipios.php
  module ChaveAcesso
    # 6 números (cUF e AAMM), 12 letras ou números (raiz e ordem do CNPJ) e 26
    # números (dígitos do CNPJ e o resto da chave).
    PATTERN = /\A\d{6}[0-9A-Z]{12}\d{26}\z/

    # Códigos IBGE das 27 UFs (o cUF, dois primeiros dígitos da chave).
    UFS_IBGE = %w[
      11 12 13 14 15 16 17
      21 22 23 24 25 26 27 28 29
      31 32 33 35
      41 42 43
      50 51 52 53
    ].freeze

    # O DANFE imprime a chave em grupos de 4, separados por espaço.
    MASK = /[.\p{Pd}[:space:]]/

    # Tira a máscara e passa as letras do CNPJ para maiúsculas.
    # O upcase(:ascii) está explicado no CNPJ.
    def self.strip(value)
      BrValidators.texto(value).gsub(MASK, "").upcase(:ascii)
    end

    def self.valid?(value)
      valid_stripped?(strip(value))
    end

    # Devolve a chave em 11 grupos de 4 ("3526 1011 2223 ..."), ou nil se for inválida.
    def self.format(value)
      chave = strip(value)
      return nil unless valid_stripped?(chave)

      chave.scan(/.{4}/).join(" ")
    end

    # O código do modelo ("55" para NF-e, "65" para NFC-e...), ou nil se for inválida.
    def self.modelo(value)
      chave = strip(value)
      valid_stripped?(chave) ? chave[20, 2] : nil
    end

    # A regra, com a chave já sem máscara. O dígito é o módulo 11 com pesos de 2 a 9
    # (Digitos, em digitos.rb), com as letras do CNPJ valendo ASCII menos 48.
    def self.valid_stripped?(chave)
      return false unless chave.match?(PATTERN)
      return false unless UFS_IBGE.include?(chave[0, 2]) && chave[4, 2].between?("01", "12")

      chave[43] == Digitos.modulo11(chave[0, 43]).to_s
    end

    private_class_method :valid_stripped?
  end
end
