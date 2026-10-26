# frozen_string_literal: true

require_relative "br_validators/version"
require_relative "br_validators/texto"
require_relative "br_validators/cpf"
require_relative "br_validators/cnpj"
require_relative "br_validators/cns"
require_relative "br_validators/pix"
require_relative "br_validators/boleto"
require_relative "br_validators/cep"
require_relative "br_validators/telefone"
require_relative "br_validators/placa"
require_relative "br_validators/renavam"
require_relative "br_validators/titulo_eleitor"
require_relative "br_validators/processo_cnj"
require_relative "br_validators/chave_acesso"

# Validação e formatação de documentos brasileiros.
#
# Cada documento tem um módulo próprio (BrValidators::CPF, BrValidators::CNPJ...)
# com os mesmos três métodos:
#   valid?(valor)  -> true ou false
#   format(valor)  -> o documento com a máscara, ou nil se for inválido
#   strip(valor)   -> o documento sem a máscara
# A chave Pix é a exceção: tem valid? e type, mas não format nem strip, porque
# precisa estar exatamente como o Banco Central guarda.
# Alguns têm métodos a mais: type (Pix, Boleto, Telefone, Placa), uf (TituloEleitor),
# segmento (ProcessoCNJ), modelo (ChaveAcesso), ddd (Telefone), mercosul e antiga (Placa).
module BrValidators
end

# Validação nos models (validates :cpf, cpf: true): só entra quando o projeto tem
# o ActiveModel (todo app Rails tem), para a gem continuar sem dependências.
require_relative "br_validators/active_model" if Gem.loaded_specs.key?("activemodel")
