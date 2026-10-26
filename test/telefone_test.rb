# frozen_string_literal: true

require "test_helper"

# Números fictícios, criados só para os testes.
describe BrValidators::Telefone do
  subject { BrValidators::Telefone }

  describe ".type" do
    it "reconhece celular e fixo, com e sem máscara" do
      assert_equal :celular, subject.type("(11) 98765-4321")
      assert_equal :celular, subject.type("11987654321")
      assert_equal :fixo, subject.type("(11) 3456-7890")
      assert_equal :fixo, subject.type("4834567890")
    end

    it "aceita o código do país e o zero antes do DDD" do
      assert_equal :celular, subject.type("+55 11 98765-4321")
      assert_equal :celular, subject.type("5511987654321")
      assert_equal :fixo, subject.type("+55 (48) 3456-7890")
      assert_equal :celular, subject.type("011 98765-4321")
      assert_equal :fixo, subject.type("0 48 3456-7890")
    end

    it "não confunde o DDD 55 com o código do país" do
      assert_equal :celular, subject.type("(55) 98765-4321")
      assert_equal :fixo, subject.type("(55) 3456-7890")
      assert_equal :celular, subject.type("+55 55 98765-4321")
    end

    it "recusa DDD que não existe" do
      refute subject.type("(20) 98765-4321")
      refute subject.type("(36) 3456-7890")
      refute subject.type("(10) 98765-4321")
    end

    it "recusa celular sem o nono dígito e fixo que começa com 6 a 9 ou 0 e 1" do
      assert_nil subject.type("(11) 8765-4321")
      assert_nil subject.type("(11) 88765-4321")
      assert_nil subject.type("(11) 6456-7890")
      assert_nil subject.type("(11) 1456-7890")
    end

    it "recusa tamanho errado, letras, vazio e nil" do
      assert_nil subject.type("1198765432100")
      assert_nil subject.type("119876")
      assert_nil subject.type("(11) 9876A-4321")
      assert_nil subject.type("")
      assert_nil subject.type(nil)
    end

    it "recusa texto com bytes inválidos sem levantar erro" do
      assert_nil subject.type("11987654321\xFF".dup.force_encoding(Encoding::UTF_8))
    end
  end

  describe ".valid?" do
    it "diz se o número é válido" do
      assert subject.valid?("(21) 2345-6789")
      refute subject.valid?("(21) 1234-5678")
    end
  end

  describe ".format" do
    it "formata celular e fixo, sem o código do país" do
      assert_equal "(11) 98765-4321", subject.format("+5511987654321")
      assert_equal "(48) 3456-7890", subject.format("04834567890")
    end

    it "devolve nil para número inválido" do
      assert_nil subject.format("(20) 98765-4321")
    end
  end

  describe ".ddd" do
    it "devolve o DDD ou nil" do
      assert_equal "48", subject.ddd("+55 48 3456-7890")
      assert_nil subject.ddd("123")
    end
  end

  describe ".strip" do
    it "tira parênteses, +, hífen e espaços" do
      assert_equal "5511987654321", subject.strip("+55 (11) 98765-4321")
    end
  end
end
