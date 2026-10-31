# frozen_string_literal: true

require "test_helper"
require "open3"
require "rbconfig"

# require "br_validators/documentos" é a saída para o app que já tem um
# CpfValidator próprio. Cada teste roda o código num Ruby separado, porque neste
# processo os validadores do ActiveModel já foram carregados pelo test_helper.
describe "br_validators/documentos" do
  let(:codigo) { 'require "active_model"; require "br_validators/documentos"; print defined?(CpfValidator).inspect' }

  subject do
    saida, status = Open3.capture2e(RbConfig.ruby, "-I", File.expand_path("../lib", __dir__), "-e", codigo)
    assert status.success?, saida
    saida.strip
  end

  it "carrega os documentos sem criar os validadores do Rails, mesmo com o ActiveModel" do
    assert_equal "nil", subject
  end

  describe "com os documentos" do
    let(:codigo) { 'require "br_validators/documentos"; print BrValidators::CPF.valid?("123.456.789-09")' }

    it "valida como o require normal" do
      assert_equal "true", subject
    end
  end

  describe "com as consultas" do
    let(:codigo) { 'require "active_model"; require "br_validators/consulta"; print defined?(CpfValidator).inspect' }

    it "não traz os validadores do Rails junto" do
      assert_equal "nil", subject
    end
  end

  describe "pedindo os validadores do Rails direto" do
    let(:codigo) { 'require "br_validators/active_model"; print CpfValidator::DOCUMENT' }

    it "traz os documentos junto" do
      assert_equal "BrValidators::CPF", subject
    end
  end
end
