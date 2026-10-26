# frozen_string_literal: true

module BrValidators
  # Telefone brasileiro, fixo ou celular, com DDD.
  #
  # - DDD: um dos 67 códigos nacionais da Anatel.
  # - Celular: 9 dígitos começando com 9 (o "nono dígito", Resolução Anatel
  #   553/2010).
  # - Fixo: 8 dígitos começando com 2, 3, 4 ou 5 (faixa da telefonia fixa no
  #   Regulamento de Numeração, Resolução Anatel 86/1998, art. 19, com a redação da
  #   Resolução 553/2010; a 86/1998 foi revogada pela 749/2022 e os números em uso
  #   continuam nesse formato).
  #
  # Aceita o código do país (+55) e o zero antes do DDD ("011..."). Não aceita o
  # código da operadora (0 XX DDD ...) nem números especiais, como 0800 e 190.
  #
  # Fontes:
  # - Lista dos 67 códigos nacionais (DDD): perguntas frequentes da Anatel sobre
  #   áreas locais, 2026.
  #   https://sistemas.anatel.gov.br/anexar-api/publico/anexos/download/a8c6650c72539ff2334c327ab5c169e4
  # - Resolução 86/1998 (Regulamento de Numeração do STFC) e Resolução 553/2010.
  module Telefone
    # Os 67 DDDs em uso. Os que faltam na sequência (20, 23, 25, 26, 29, 30,
    # 36, 39, 40, 50, 52, 56 a 60, 70, 72, 76, 78, 80 e 90) não existem.
    DDDS = %w[
      11 12 13 14 15 16 17 18 19
      21 22 24 27 28
      31 32 33 34 35 37 38
      41 42 43 44 45 46 47 48 49
      51 53 54 55
      61 62 63 64 65 66 67 68 69
      71 73 74 75 77 79
      81 82 83 84 85 86 87 88 89
      91 92 93 94 95 96 97 98 99
    ].freeze

    CELULAR = /\A9\d{8}\z/
    FIXO = /\A[2-5]\d{7}\z/

    # Parênteses, "+", pontos, hífens e espaços.
    MASK = /[()+.\-[:space:]]/

    # Tira a máscara: "+55 (11) 98765-4321" vira "5511987654321".
    # O scrub está explicado no CPF: texto corrompido vira inválido, sem erro.
    def self.strip(value)
      value.to_s.scrub.gsub(MASK, "")
    end

    # :celular, :fixo ou nil se o número for inválido.
    def self.type(value)
      numero = nacional(value)
      return nil unless numero && DDDS.include?(numero[0, 2])

      assinante = numero[2..]
      return :celular if assinante.match?(CELULAR)
      return :fixo if assinante.match?(FIXO)

      nil
    end

    def self.valid?(value)
      !type(value).nil?
    end

    # Devolve "(11) 98765-4321" ou "(11) 3456-7890", ou nil se for inválido.
    def self.format(value)
      return nil unless valid?(value)

      numero = nacional(value)
      "(#{numero[0, 2]}) #{numero[2...-4]}-#{numero[-4..]}"
    end

    # O DDD ("11"), ou nil se o número for inválido.
    def self.ddd(value)
      valid?(value) ? nacional(value)[0, 2] : nil
    end

    # O número só com DDD e assinante (10 ou 11 dígitos), sem o código do país
    # (55) nem o zero antes do DDD. Devolve nil se não sobrar um número desse tamanho.
    def self.nacional(value)
      digits = strip(value)
      return nil unless digits.match?(/\A\d+\z/)

      # Com o código do país: 55 + 10 ou 11 dígitos.
      digits = digits.delete_prefix("55") if digits.start_with?("55") && digits.size.between?(12, 13)
      # O DDD nunca começa com 0; um zero na frente é o prefixo de chamada nacional.
      digits = digits.delete_prefix("0") if digits.start_with?("0")

      digits.size.between?(10, 11) ? digits : nil
    end

    private_class_method :nacional
  end
end
