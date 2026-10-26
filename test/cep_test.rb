# frozen_string_literal: true

require "test_helper"

# CEPs usados só como exemplo de formato.
describe BrValidators::CEP do
  subject { BrValidators::CEP }

  describe ".valid?" do
    it "aceita CEP com e sem máscara" do
      assert subject.valid?("01001-000")
      assert subject.valid?("01001000")
      assert subject.valid?(" 70040.010 ")
    end

    it "aceita espaço não separável" do
      assert subject.valid?("01001 000")
    end

    it "recusa o CEP zerado, tamanho errado, letras, vazio e nil" do
      refute subject.valid?("00000-000")
      refute subject.valid?("0100100")
      refute subject.valid?("010010000")
      refute subject.valid?("01001-00A")
      refute subject.valid?("")
      refute subject.valid?(nil)
    end

    it "recusa texto com bytes inválidos sem levantar erro" do
      refute subject.valid?("01001000\xFF".dup.force_encoding(Encoding::UTF_8))
    end
  end

  describe ".format" do
    it "coloca o hífen" do
      assert_equal "01001-000", subject.format("01001000")
    end

    it "devolve nil para CEP inválido" do
      assert_nil subject.format("123")
    end
  end

  describe ".strip" do
    it "tira pontos, hífen e espaços" do
      assert_equal "70040010", subject.strip(" 70.040-010 ")
    end
  end
end
