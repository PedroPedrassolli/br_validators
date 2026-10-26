# frozen_string_literal: true

require "test_helper"

# 1023 8501 0671 é o exemplo da OBMEP; os outros são fictícios, gerados para os testes.
describe BrValidators::TituloEleitor do
  subject { BrValidators::TituloEleitor }

  describe ".valid?" do
    it "aceita título com e sem máscara" do
      assert subject.valid?("1023 8501 0671")
      assert subject.valid?("102385010671")
      assert subject.valid?("1234.5678.0191")
    end

    it "aceita título emitido no exterior (ZZ)" do
      assert subject.valid?("123456782895")
    end

    it "em SP e MG, resto 0 vira dígito 1; nas outras UFs, vira 0" do
      assert subject.valid?("100000010116")
      assert subject.valid?("100000010302")
      refute subject.valid?("100000010106")
    end

    it "recusa dígito errado e UF que não existe" do
      refute subject.valid?("102385010672")
      refute subject.valid?("123456782995")
      refute subject.valid?("123456780091")
    end

    it "recusa tamanho errado (inclusive os de 13 dígitos), letras, vazio e nil" do
      refute subject.valid?("10238501067")
      refute subject.valid?("1023850106711")
      refute subject.valid?("10238501067A")
      refute subject.valid?("")
      refute subject.valid?(nil)
    end

    it "recusa texto com bytes inválidos sem levantar erro" do
      refute subject.valid?("102385010671\xFF".dup.force_encoding(Encoding::UTF_8))
    end
  end

  describe ".format" do
    it "agrupa de 4 em 4" do
      assert_equal "1023 8501 0671", subject.format("102385010671")
    end

    it "devolve nil para título inválido" do
      assert_nil subject.format("102385010672")
    end
  end

  describe ".uf" do
    it "devolve a sigla da UF de emissão" do
      assert_equal "PR", subject.uf("1023 8501 0671")
      assert_equal "SP", subject.uf("123456780191")
      assert_equal "ZZ", subject.uf("123456782895")
    end

    it "devolve nil para título inválido" do
      assert_nil subject.uf("102385010672")
    end
  end

  describe ".strip" do
    it "tira espaços, pontos, barras e hífens" do
      assert_equal "102385010671", subject.strip("1023 8501/06-71")
    end
  end
end
