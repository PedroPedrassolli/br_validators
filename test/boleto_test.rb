# frozen_string_literal: true

require "test_helper"

# Linhas digitáveis fictícias, montadas só para os testes.
describe BrValidators::Boleto do
  subject { BrValidators::Boleto }

  let(:cobranca) { "00190000090234567890412345678176110000000012345" }
  let(:cobranca_sem_vencimento) { "23799999949999999999099999999990200000000000000" }
  let(:arrecadacao_modulo10) { "826700000019000000000000000000000000000000000000" }
  let(:arrecadacao_modulo11) { "838500000059678123456783901234567894012345678900" }

  describe ".type" do
    it "reconhece boleto de cobrança" do
      assert_equal :cobranca, subject.type(cobranca)
      assert_equal :cobranca, subject.type(cobranca_sem_vencimento)
    end

    it "reconhece boleto de arrecadação de módulo 10 e de módulo 11" do
      assert_equal :arrecadacao, subject.type(arrecadacao_modulo10)
      assert_equal :arrecadacao, subject.type(arrecadacao_modulo11)
      assert_equal :arrecadacao, subject.type("817711111119111111111113111111111113111111111113")
      assert_equal :arrecadacao, subject.type("859001234561789012345675890123456785901234567894")
    end

    it "devolve nil para linha inválida, vazia ou nil" do
      assert_nil subject.type("1234")
      assert_nil subject.type("")
      assert_nil subject.type(nil)
    end
  end

  describe ".valid?" do
    it "aceita a linha com a máscara impressa no boleto" do
      assert subject.valid?("00190.00009 02345.678904 12345.678176 1 10000000012345")
      assert subject.valid?("82670000001-9 00000000000-0 00000000000-0 00000000000-0")
    end

    it "recusa cobrança com dígito errado em um dos três primeiros campos" do
      refute subject.valid?(cobranca.sub(/\A(\d{9})\d/, '\10'))
      refute subject.valid?(cobranca.sub(/\A(\d{20})\d/, '\10'))
      refute subject.valid?(cobranca.sub(/\A(\d{31})\d/, '\10'))
    end

    it "recusa cobrança com dígito verificador geral errado" do
      refute subject.valid?(cobranca.sub(/\A(\d{32})\d/, '\12'))
    end

    it "recusa cobrança com o valor alterado" do
      refute subject.valid?(cobranca.sub(/\d\z/, "6"))
    end

    it "recusa arrecadação com dígito de bloco ou dígito geral errado" do
      refute subject.valid?(arrecadacao_modulo10.sub(/\A(\d{11})\d/, '\10'))
      refute subject.valid?(arrecadacao_modulo11.sub(/\A(\d{3})\d/, '\11'))
    end

    it "recusa arrecadação com identificador de valor que não é 6, 7, 8 ou 9" do
      refute subject.valid?("825700000019000000000000000000000000000000000000")
    end

    it "recusa linha com 48 dígitos que não começa com 8" do
      refute subject.valid?("726700000019000000000000000000000000000000000000")
    end

    it "recusa letras" do
      refute subject.valid?(cobranca.sub(/\d\z/, "A"))
    end
  end

  describe ".format" do
    it "coloca a máscara de cobrança" do
      assert_equal "00190.00009 02345.678904 12345.678176 1 10000000012345", subject.format(cobranca)
    end

    it "coloca a máscara de arrecadação" do
      assert_equal "82670000001-9 00000000000-0 00000000000-0 00000000000-0", subject.format(arrecadacao_modulo10)
    end

    it "devolve nil para linha inválida" do
      assert_nil subject.format("1234")
    end
  end

  describe ".strip" do
    it "tira pontos, espaços e hífens" do
      assert_equal cobranca, subject.strip("00190.00009 02345.678904 12345.678176 1 10000000012345")
    end

    it "devolve texto vazio para nil" do
      assert_equal "", subject.strip(nil)
    end
  end
end
