# frozen_string_literal: true

require_relative "version"
require_relative "texto"
require_relative "cpf"
require_relative "cnpj"
require_relative "cns"
require_relative "pix"
require_relative "boleto"
require_relative "cep"
require_relative "telefone"
require_relative "placa"
require_relative "renavam"
require_relative "titulo_eleitor"
require_relative "processo_cnj"
require_relative "chave_acesso"

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
#
# Este arquivo carrega só os documentos, sem os validadores do Rails. Serve para o
# app que já tem um CpfValidator (ou outro com o mesmo nome) e quer continuar com o
# dele: no Gemfile, gem "br_validators", require: "br_validators/documentos".
module BrValidators
end
