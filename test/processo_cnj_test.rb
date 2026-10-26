# frozen_string_literal: true

require "test_helper"

# Números fictícios (unidade de origem 9999), gerados só para os testes.
describe BrValidators::ProcessoCNJ do
  subject { BrValidators::ProcessoCNJ }

  describe ".valid?" do
    it "aceita número com e sem máscara" do
      assert subject.valid?("0000123-37.2024.8.26.9999")
      assert subject.valid?("00001233720248269999")
      assert subject.valid?("0000456-41.2023.5.02.9999")
      assert subject.valid?("0000789-81.2022.4.03.9999")
    end

    it "recusa dígito verificador errado" do
      refute subject.valid?("0000123-38.2024.8.26.9999")
      refute subject.valid?("0000124-37.2024.8.26.9999")
    end

    it "recusa segmento 0, que não existe" do
      refute subject.valid?("0000123-37.2024.0.26.9999")
    end

    it "recusa tamanho errado, letras, vazio e nil" do
      refute subject.valid?("000123-37.2024.8.26.9999")
      refute subject.valid?("0000123-37.2024.8.26.999A")
      refute subject.valid?("")
      refute subject.valid?(nil)
    end

    it "recusa texto com bytes inválidos sem levantar erro" do
      refute subject.valid?("00001233720248269999\xFF".dup.force_encoding(Encoding::UTF_8))
    end
  end

  describe ".format" do
    it "coloca a máscara da numeração única" do
      assert_equal "0000123-37.2024.8.26.9999", subject.format("00001233720248269999")
    end

    it "devolve nil para número inválido" do
      assert_nil subject.format("00001233820248269999")
    end
  end

  describe ".segmento" do
    it "devolve o nome do segmento do Judiciário" do
      assert_equal "Justiça dos Estados e do Distrito Federal", subject.segmento("0000123-37.2024.8.26.9999")
      assert_equal "Justiça do Trabalho", subject.segmento("0000456-41.2023.5.02.9999")
    end

    it "devolve nil para número inválido" do
      assert_nil subject.segmento("0000123-38.2024.8.26.9999")
    end
  end

  describe ".strip" do
    it "tira pontos, hífen e espaços" do
      assert_equal "00001233720248269999", subject.strip(" 0000123-37.2024.8.26.9999 ")
    end
  end
end
