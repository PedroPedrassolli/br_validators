# frozen_string_literal: true

# validates :chave_pix, pix: true
class PixValidator < BrValidators::DocumentValidator
  DOCUMENT = BrValidators::Pix
  ERROR = :pix_invalid
end
