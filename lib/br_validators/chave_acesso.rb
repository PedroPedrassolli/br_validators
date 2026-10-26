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
  # todo o resto continua só com números.
  #
  # O dígito verificador usa módulo 11 com pesos de 2 a 9, da direita para a
  # esquerda, sobre os 43 primeiros caracteres. Cada caractere vale o código ASCII
  # dele menos 48 (como no CNPJ alfanumérico: "0" vale 0, "A" vale 17). Se o resto
  # for 0 ou 1, o dígito é 0; senão, é 11 menos o resto.
  #
  # Fontes: Manual de Orientação do Contribuinte da NF-e e Nota Técnica Conjunta
  # 2025.001 (CNPJ alfanumérico nos documentos fiscais eletrônicos), publicados no
  # Portal da NF-e. https://www.nfe.fazenda.gov.br/portal/
  module ChaveAcesso
    # 6 números (cUF e AAMM), 12 letras ou números (raiz e ordem do CNPJ) e 26
    # números (dígitos do CNPJ e o resto da chave).
    PATTERN = /\A\d{6}[0-9A-Z]{12}\d{26}\z/

    # O DANFE imprime a chave em grupos de 4, separados por espaço.
    MASK = /[.\-[:space:]]/

    # Tira a máscara e passa as letras do CNPJ para maiúsculas.
    # upcase(:ascii) e scrub estão explicados no CNPJ e no CPF.
    def self.strip(value)
      value.to_s.scrub.gsub(MASK, "").upcase(:ascii)
    end

    def self.valid?(value)
      chave = strip(value)
      return false unless chave.match?(PATTERN)

      chave[43] == check_digit(chave[0, 43])
    end

    # Devolve a chave em 11 grupos de 4 ("3526 1011 2223 ..."), ou nil se for inválida.
    def self.format(value)
      return nil unless valid?(value)

      strip(value).scan(/.{4}/).join(" ")
    end

    # O código do modelo ("55" para NF-e, "65" para NFC-e...), ou nil se for inválida.
    def self.modelo(value)
      valid?(value) ? strip(value)[20, 2] : nil
    end

    def self.check_digit(chars)
      sum = chars.reverse.chars.each_with_index.sum { |char, index| (char.ord - 48) * ((index % 8) + 2) }
      rest = sum % 11
      (rest < 2 ? 0 : 11 - rest).to_s
    end

    private_class_method :check_digit
  end
end
