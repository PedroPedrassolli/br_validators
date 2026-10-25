# frozen_string_literal: true

source "https://rubygems.org"

# As informações da gem (nome, versão, Ruby mínimo) ficam no br_validators.gemspec.
gemspec

# Só para desenvolvimento e testes. Quem instala a gem não recebe nenhuma delas,
# e a função da Vercel (api/validar.rb) também não: ela usa BUNDLE_WITHOUT.
group :development, :test do
  gem "activemodel"
  gem "minitest"
  gem "rake"
  gem "rubocop", require: false
  gem "simplecov", require: false
end
