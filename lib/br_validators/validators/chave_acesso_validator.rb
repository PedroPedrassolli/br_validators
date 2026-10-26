# frozen_string_literal: true

# validates :chave_nfe, chave_acesso: true
class ChaveAcessoValidator < BrValidators::DocumentValidator
  DOCUMENT = BrValidators::ChaveAcesso
  ERROR = :chave_acesso_invalid
end
