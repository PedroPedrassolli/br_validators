# frozen_string_literal: true

# validates :cns, cns: true
class CnsValidator < BrValidators::DocumentValidator
  DOCUMENT = BrValidators::CNS
  ERROR = :cns_invalid
end
