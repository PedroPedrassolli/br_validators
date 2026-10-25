# frozen_string_literal: true

require_relative "br_validators/version"
require_relative "br_validators/cpf"

# Validação e formatação de documentos brasileiros.
#
# Cada documento tem um módulo próprio (BrValidators::CPF, BrValidators::CNPJ...)
# com os mesmos três métodos:
#   valid?(valor)  -> true ou false
#   format(valor)  -> o documento com a máscara, ou nil se for inválido
#   strip(valor)   -> o documento sem a máscara
module BrValidators
end
