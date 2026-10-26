# frozen_string_literal: true

# validates :celular, telefone: true
class TelefoneValidator < BrValidators::DocumentValidator
  DOCUMENT = BrValidators::Telefone
  ERROR = :telefone_invalid
end
