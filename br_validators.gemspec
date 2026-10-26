# frozen_string_literal: true

require_relative "lib/br_validators/version"

Gem::Specification.new do |spec|
  spec.name = "br_validators"
  spec.version = BrValidators::VERSION
  spec.authors = ["Pedro Pedrassolli"]
  spec.email = ["pedropedrassolli@outlook.com"]

  spec.summary = "Valida e formata documentos brasileiros: CPF, CNPJ alfanumérico, CNS, Pix, boleto, CEP, " \
                 "telefone, placa, RENAVAM, título de eleitor, chave de NF-e e processo do CNJ."
  spec.homepage = "https://github.com/PedroPedrassolli/br_validators"
  spec.license = "MIT"

  # 3.3 é a versão mais antiga do Ruby que ainda recebe correções de segurança.
  spec.required_ruby_version = ">= 3.3"

  spec.metadata = {
    "source_code_uri" => spec.homepage,
    "changelog_uri" => "#{spec.homepage}/blob/main/CHANGELOG.md",
    "bug_tracker_uri" => "#{spec.homepage}/issues",
    "rubygems_mfa_required" => "true"
  }

  # Só o código e os textos vão para o pacote; testes e workflows ficam no repositório.
  spec.files = Dir["lib/**/*.{rb,yml}", "README.md", "CHANGELOG.md", "LICENSE"]

  # Sem dependências em tempo de execução: a integração com o ActiveModel só é
  # carregada quando a aplicação já tem o Rails (ou o ActiveModel) instalado.
end
