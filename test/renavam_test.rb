# frozen_string_literal: true

require "test_helper"

# Códigos fictícios, gerados só para os testes.
describe BrValidators::RENAVAM do
  subject { BrValidators::RENAVAM }

  describe ".valid?" do
    it "aceita RENAVAM com dígito verificador correto" do
      assert subject.valid?("00123456789")
      assert subject.valid?("63986815096")
      assert subject.valid?(" 0012345678-9 ")
    end

    it "aceita dígito 0 quando o resto é 0 ou 1" do
      assert subject.valid?("12345678900")
    end

    it "recusa dígito errado, todos iguais e tamanho errado" do
      refute subject.valid?("00123456780")
      refute subject.valid?("00000000000")
      refute subject.valid?("123456789")
      refute subject.valid?("001234567890")
    end

    it "recusa letras, vazio, nil e bytes inválidos" do
      refute subject.valid?("0012345678A")
      refute subject.valid?("")
      refute subject.valid?(nil)
      refute subject.valid?("00123456789\xFF".dup.force_encoding(Encoding::UTF_8))
    end
  end

  describe ".format" do
    it "devolve os 11 dígitos, sem máscara" do
      assert_equal "00123456789", subject.format("0012345678-9")
    end

    it "devolve nil para RENAVAM inválido" do
      assert_nil subject.format("00123456780")
    end
  end

  describe ".strip" do
    it "tira pontos, hífen e espaços" do
      assert_equal "00123456789", subject.strip(" 001.234.567-89 ")
    end
  end
end
