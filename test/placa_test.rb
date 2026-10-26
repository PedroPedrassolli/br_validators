# frozen_string_literal: true

require "test_helper"

# Placas fictícias; ABC-1234 → ABC1C34 é o exemplo da Resolução CONTRAN 780/2019.
describe BrValidators::Placa do
  subject { BrValidators::Placa }

  describe ".type" do
    it "reconhece a placa antiga e a Mercosul, com e sem máscara" do
      assert_equal :antiga, subject.type("ABC-1234")
      assert_equal :antiga, subject.type("abc1234")
      assert_equal :mercosul, subject.type("ABC1C34")
      assert_equal :mercosul, subject.type(" bra2e19 ")
    end

    it "recusa outros formatos, vazio e nil" do
      assert_nil subject.type("AB-12345")
      assert_nil subject.type("ABC12C4")
      assert_nil subject.type("1BC1234")
      assert_nil subject.type("ABC123")
      assert_nil subject.type("")
      assert_nil subject.type(nil)
    end

    it "recusa letras fora do ASCII e bytes inválidos sem levantar erro" do
      assert_nil subject.type("ABı1234")
      assert_nil subject.type("ABC1234\xFF".dup.force_encoding(Encoding::UTF_8))
    end
  end

  describe ".valid?" do
    it "diz se a placa é válida" do
      assert subject.valid?("RIO2A18")
      refute subject.valid?("RIO-2A18X")
    end
  end

  describe ".format" do
    it "põe o hífen só na placa antiga" do
      assert_equal "ABC-1234", subject.format("abc1234")
      assert_equal "BRA2E19", subject.format("bra-2e19")
    end

    it "devolve nil para placa inválida" do
      assert_nil subject.format("ABC")
    end
  end

  describe ".mercosul" do
    it "converte a placa antiga trocando o quinto caractere" do
      assert_equal "ABC1C34", subject.mercosul("ABC-1234")
      assert_equal "XYZ9A99", subject.mercosul("XYZ-9099")
      assert_equal "XYZ9J99", subject.mercosul("XYZ-9999")
    end

    it "devolve a placa Mercosul como está e nil para inválida" do
      assert_equal "BRA2E19", subject.mercosul("bra2e19")
      assert_nil subject.mercosul("ABC")
    end
  end

  describe ".antiga" do
    it "desfaz a conversão das letras de A a J" do
      assert_equal "ABC1234", subject.antiga("ABC1C34")
      assert_equal "XYZ9999", subject.antiga("XYZ9J99")
      assert_equal "ABC1234", subject.antiga("abc-1234")
    end

    it "devolve nil para Mercosul com letra depois do J e para placa inválida" do
      assert_nil subject.antiga("ABC1K34")
      assert_nil subject.antiga("ABC")
    end
  end

  describe ".strip" do
    it "tira o hífen e passa para maiúsculas" do
      assert_equal "ABC1234", subject.strip("abc-1234")
    end
  end
end
