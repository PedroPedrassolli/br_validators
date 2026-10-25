# frozen_string_literal: true

require "test_helper"

# Chaves fictícias, criadas só para os testes.
describe BrValidators::Pix do
  subject { BrValidators::Pix }

  describe ".type" do
    it "reconhece CPF e CNPJ sem máscara" do
      assert_equal :cpf, subject.type("12345678909")
      assert_equal :cnpj, subject.type("11222333000181")
      assert_equal :cnpj, subject.type("12ABC34501DE35")
    end

    it "reconhece celular, e-mail e chave aleatória" do
      assert_equal :phone, subject.type("+5511987654321")
      assert_equal :email, subject.type("maria.souza@exemplo.com.br")
      assert_equal :evp, subject.type("123e4567-e89b-12d3-a456-426655440000")
    end

    it "ignora espaços nas pontas" do
      assert_equal :phone, subject.type(" +5511987654321 ")
    end

    it "devolve nil para chave inválida, vazia ou nil" do
      assert_nil subject.type("chave qualquer")
      assert_nil subject.type("")
      assert_nil subject.type(nil)
    end
  end

  describe ".valid?" do
    it "recusa CPF e CNPJ com máscara ou com dígito verificador errado" do
      refute subject.valid?("123.456.789-09")
      refute subject.valid?("11.222.333/0001-81")
      refute subject.valid?("12345678900")
      refute subject.valid?("11222333000180")
    end

    it "recusa CNPJ alfanumérico em minúsculas" do
      refute subject.valid?("12abc34501de35")
    end

    it "recusa celular sem o + ou com máscara" do
      refute subject.valid?("5511987654321")
      refute subject.valid?("+55 (11) 98765-4321")
    end

    it "recusa celular com código do país começando em zero ou longo demais" do
      refute subject.valid?("+0511987654321")
      refute subject.valid?("+551198765432101234")
    end

    it "recusa e-mail com maiúsculas, sem domínio ou longo demais" do
      refute subject.valid?("Maria.Souza@exemplo.com.br")
      refute subject.valid?("maria.souza@")
      refute subject.valid?("#{'a' * 66}@exemplo.com")
    end

    it "aceita e-mail com os símbolos que a especificação permite" do
      assert subject.valid?("maria+pix@exemplo.com")
      assert subject.valid?("a#b$c&d@exemplo.com")
    end

    it "aceita e-mail com exatamente 77 caracteres" do
      assert subject.valid?("#{'a' * 65}@exemplo.com")
    end

    it "recusa chave aleatória em maiúsculas ou sem hífens" do
      refute subject.valid?("123E4567-E89B-12D3-A456-426655440000")
      refute subject.valid?("123e4567e89b12d3a456426655440000")
    end
  end

  describe "entradas copiadas ou corrompidas" do
    it "ignora espaços Unicode nas pontas, mas não no meio" do
      assert_equal :phone, subject.type("\u00A0+5511987654321\u00A0")
      assert_nil subject.type("+55\u00A011987654321")
    end

    it "recusa texto com bytes inválidos sem levantar erro" do
      assert_nil subject.type("maria@exemplo.com\xFF".dup.force_encoding(Encoding::UTF_8))
    end
  end
end
