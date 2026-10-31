# frozen_string_literal: true

# Os documentos (BrValidators::CPF, BrValidators::CNPJ...). A explicação de cada
# método está em br_validators/documentos.rb.
require_relative "br_validators/documentos"

# Validação nos models (validates :cpf, cpf: true): só entra quando o projeto tem
# o ActiveModel (todo app Rails tem), para a gem continuar sem dependências.
require_relative "br_validators/active_model" if Gem.loaded_specs.key?("activemodel")
