# frozen_string_literal: true

module BrValidators
  # CNS (Cartão Nacional de Saúde): 15 dígitos, só números.
  #
  # A validação segue as duas rotinas do Ministério da Saúde:
  # - Números que começam com 1 ou 2 são gerados a partir do PIS (os 11 primeiros
  #   dígitos). A soma do PIS com pesos de 15 a 5 dá o dígito verificador; o número
  #   esperado é PIS + "000" + DV, ou PIS + "001" + DV quando a primeira conta dá 10.
  # - Números que começam com 7, 8 ou 9 são válidos quando a soma dos 15 dígitos,
  #   com pesos de 15 a 1, é divisível por 11.
  # Qualquer outro primeiro dígito é inválido.
  #
  # O CNS não tem máscara oficial. O 16º número impresso no cartão é o número da
  # via e não faz parte do CNS.
  #
  # Fonte: regras de validação do CNS publicadas pela Anvisa, com as rotinas do
  # Ministério da Saúde.
  # https://rni-docs.anvisa.gov.br/docs/regras_gerais/validacoes/validacaoCNS/
  module CNS
    # O cartão mostra o número em grupos separados por espaço; aceitamos também
    # pontos e hífens, que às vezes aparecem em sistemas antigos. Espaços Unicode
    # (como o não separável) também contam como espaço.
    MASK = /[.\p{Pd}[:space:]]/

    def self.strip(value)
      BrValidators.texto(value).gsub(MASK, "")
    end

    def self.valid?(value)
      valid_stripped?(strip(value))
    end

    # Devolve o CNS em grupos de 3, 4, 4 e 4 dígitos, como aparece impresso no
    # cartão ("123 4567 8901 0000"), ou nil se for inválido.
    def self.format(value)
      cns = strip(value)
      return nil unless valid_stripped?(cns)

      "#{cns[0, 3]} #{cns[3, 4]} #{cns[7, 4]} #{cns[11, 4]}"
    end

    # A regra, com o CNS já sem máscara.
    def self.valid_stripped?(cns)
      return false unless cns.match?(/\A\d{15}\z/)

      case cns[0]
      when "1", "2" then cns == from_pis(cns[0, 11])
      when "7", "8", "9" then (weighted_sum(cns) % 11).zero?
      else false
      end
    end

    # Monta o CNS esperado para um PIS, como na rotina do Ministério da Saúde.
    def self.from_pis(pis)
      sum = weighted_sum(pis)
      digit = 11 - (sum % 11)
      digit = 0 if digit == 11
      return "#{pis}000#{digit}" unless digit == 10

      # Quando o dígito dá 10, a rotina soma 2 e coloca "001" no meio.
      digit = 11 - ((sum + 2) % 11)
      "#{pis}001#{digit}"
    end

    # Pesos começando em 15 e diminuindo de 1 em 1 a cada dígito. getbyte - 48 é o
    # valor do dígito (explicado em digitos.rb).
    def self.weighted_sum(digits)
      (0...digits.size).sum { |index| (digits.getbyte(index) - 48) * (15 - index) }
    end

    private_class_method :valid_stripped?, :from_pis, :weighted_sum
  end
end
