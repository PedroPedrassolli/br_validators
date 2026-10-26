# frozen_string_literal: true

# validates :renavam, renavam: true
class RenavamValidator < BrValidators::DocumentValidator
  DOCUMENT = BrValidators::RENAVAM
  ERROR = :renavam_invalid
end
