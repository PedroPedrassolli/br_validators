# frozen_string_literal: true

# validates :titulo, titulo_eleitor: true
class TituloEleitorValidator < BrValidators::DocumentValidator
  DOCUMENT = BrValidators::TituloEleitor
  ERROR = :titulo_eleitor_invalid
end
