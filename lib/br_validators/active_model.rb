# frozen_string_literal: true

require "active_model"
require_relative "documentos"

# Validação nos models do Rails (ou de qualquer classe com ActiveModel):
#
#   validates :cpf, cpf: true
#   validates :cnpj, cnpj: true, allow_blank: true
#   validates :chave_pix, pix: { message: "não parece uma chave Pix" }
#
# O Rails procura a classe pelo nome da opção ("cpf: true" vira CpfValidator),
# por isso os validadores ficam no nível de cima, fora do módulo BrValidators.
# Efeito colateral: se o app já tem um validador com o mesmo nome (por exemplo,
# app/validators/cpf_validator.rb), o Rails ignora o arquivo do app sem avisar,
# porque a classe já existe. Para ficar com o do app, o Gemfile carrega só os
# documentos: gem "br_validators", require: "br_validators/documentos".
# As mensagens de erro estão em lib/br_validators/locale (pt-BR e en).
I18n.load_path += Dir[File.expand_path("locale/*.yml", __dir__)]

module BrValidators
  # Base comum: cada validador só diz qual módulo usa e qual mensagem mostra.
  # allow_nil e allow_blank já são tratados pelo próprio ActiveModel.
  class DocumentValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      return if self.class::DOCUMENT.valid?(value)

      record.errors.add(attribute, options[:message] || self.class::ERROR)
    end
  end
end

# Um arquivo por validador: uma classe por arquivo, como no resto da gem.
require_relative "validators/cpf_validator"
require_relative "validators/cnpj_validator"
require_relative "validators/cns_validator"
require_relative "validators/pix_validator"
require_relative "validators/boleto_validator"
require_relative "validators/cep_validator"
require_relative "validators/telefone_validator"
require_relative "validators/placa_validator"
require_relative "validators/renavam_validator"
require_relative "validators/titulo_eleitor_validator"
require_relative "validators/processo_cnj_validator"
require_relative "validators/chave_acesso_validator"
