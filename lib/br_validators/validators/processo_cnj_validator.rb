# frozen_string_literal: true

# validates :processo, processo_cnj: true
class ProcessoCnjValidator < BrValidators::DocumentValidator
  DOCUMENT = BrValidators::ProcessoCNJ
  ERROR = :processo_cnj_invalid
end
