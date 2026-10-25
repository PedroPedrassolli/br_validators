# frozen_string_literal: true

# validates :cpf, cpf: true
class CpfValidator < BrValidators::DocumentValidator
  DOCUMENT = BrValidators::CPF
  ERROR = :cpf_invalid
end
