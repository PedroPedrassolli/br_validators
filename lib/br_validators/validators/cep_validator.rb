# frozen_string_literal: true

# validates :cep, cep: true
class CepValidator < BrValidators::DocumentValidator
  DOCUMENT = BrValidators::CEP
  ERROR = :cep_invalid
end
