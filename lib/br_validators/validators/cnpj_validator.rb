# frozen_string_literal: true

# validates :cnpj, cnpj: true
class CnpjValidator < BrValidators::DocumentValidator
  DOCUMENT = BrValidators::CNPJ
  ERROR = :cnpj_invalid
end
