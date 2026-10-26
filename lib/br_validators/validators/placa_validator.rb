# frozen_string_literal: true

# validates :placa, placa: true
class PlacaValidator < BrValidators::DocumentValidator
  DOCUMENT = BrValidators::Placa
  ERROR = :placa_invalid
end
