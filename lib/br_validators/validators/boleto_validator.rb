# frozen_string_literal: true

# validates :linha_digitavel, boleto: true
class BoletoValidator < BrValidators::DocumentValidator
  DOCUMENT = BrValidators::Boleto
  ERROR = :boleto_invalid
end
