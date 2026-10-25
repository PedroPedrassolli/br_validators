# frozen_string_literal: true

require "test_helper"

# Model de exemplo, só para os testes.
class Cadastro
  include ActiveModel::Validations

  attr_accessor :cpf, :cnpj, :cns, :chave_pix, :boleto

  validates :cpf, cpf: true
  validates :cnpj, cnpj: true, allow_blank: true
  validates :cns, cns: true, allow_nil: true
  validates :chave_pix, pix: { message: "não parece uma chave Pix" }, allow_nil: true
  validates :boleto, boleto: true, allow_nil: true

  def initialize(**attributes)
    attributes.each { |name, value| public_send("#{name}=", value) }
  end
end

describe "validação com ActiveModel" do
  let(:attributes) { { cpf: "123.456.789-09" } }

  subject { Cadastro.new(**attributes) }

  it "aceita um cadastro com documentos válidos" do
    attributes.merge!(cnpj: "12.ABC.345/01DE-35", cns: "898 0000 0000 0436",
                      chave_pix: "+5511987654321",
                      boleto: "00190.00009 02345.678904 12345.678176 1 10000000012345")
    assert subject.valid?
  end

  describe "com documentos inválidos" do
    let(:attributes) do
      { cpf: "111.111.111-11", cnpj: "11.222.333/0001-80", cns: "898000000000437", boleto: "1234" }
    end

    it "aponta o erro de cada campo" do
      refute subject.valid?
      assert_equal %i[cpf cnpj cns boleto], subject.errors.attribute_names
    end

    # A mensagem é montada quando é lida, então tudo fica dentro do with_locale.
    it "mostra as mensagens em português" do
      I18n.with_locale(:"pt-BR") do
        subject.valid?
        assert_equal ["não é um CPF válido"], subject.errors[:cpf]
        assert_equal ["não é um CNS válido"], subject.errors[:cns]
        assert_equal ["não é uma linha digitável de boleto válida"], subject.errors[:boleto]
      end
    end

    it "mostra as mensagens em inglês" do
      I18n.with_locale(:en) do
        subject.valid?
        assert_equal ["is not a valid CPF"], subject.errors[:cpf]
        assert_equal ["is not a valid CNPJ"], subject.errors[:cnpj]
      end
    end
  end

  describe "com allow_blank e allow_nil" do
    let(:attributes) { { cpf: "123.456.789-09", cnpj: "", cns: nil } }

    it "não valida campos vazios quando a opção permite" do
      assert subject.valid?
    end
  end

  describe "com mensagem própria" do
    let(:attributes) { { cpf: "123.456.789-09", chave_pix: "chave errada" } }

    it "usa a mensagem passada na opção" do
      refute subject.valid?
      assert_equal ["não parece uma chave Pix"], subject.errors[:chave_pix]
    end
  end

  it "exige o campo quando não há allow_nil nem allow_blank" do
    attributes[:cpf] = nil
    refute subject.valid?
  end
end
