# frozen_string_literal: true

require "test_helper"

# Números de CNS fictícios, gerados só para os testes com as rotinas do
# Ministério da Saúde.
describe BrValidators::CNS do
  subject { BrValidators::CNS }

  describe ".valid?" do
    it "aceita CNS que começa com 1 ou 2 (gerado a partir do PIS)" do
      assert subject.valid?("123456789010000")
      assert subject.valid?("200000000010009")
      assert subject.valid?("150000000000003")
    end

    it "aceita CNS de PIS em que a rotina usa 001 no meio" do
      assert subject.valid?("200000000030018")
    end

    it "aceita CNS que começa com 7, 8 ou 9" do
      assert subject.valid?("700000000000005")
      assert subject.valid?("898000000000436")
      assert subject.valid?("987654321098766")
    end

    it "aceita o número separado em grupos, como no cartão" do
      assert subject.valid?("898 0000 0000 0436")
      assert subject.valid?(" 123 4567 8901 0000 ")
    end

    it "recusa dígito verificador errado" do
      refute subject.valid?("123456789010001")
      refute subject.valid?("898000000000437")
    end

    it "recusa CNS de PIS com o meio diferente de 000 ou 001" do
      refute subject.valid?("123456789010100")
    end

    it "recusa números que começam com 0, 3, 4, 5 ou 6" do
      refute subject.valid?("000000000000000")
      refute subject.valid?("300000000000000")
      refute subject.valid?("600000000000009") # passaria na regra do 7, 8 e 9
    end

    it "recusa tamanho errado, inclusive com o número da via no fim" do
      refute subject.valid?("89800000000043")
      refute subject.valid?("8980000000004361")
    end

    it "recusa letras, vazio e nil" do
      refute subject.valid?("89800000000043A")
      refute subject.valid?("")
      refute subject.valid?(nil)
    end
  end

  describe ".format" do
    it "separa o CNS em grupos como no cartão" do
      assert_equal "898 0000 0000 0436", subject.format("898000000000436")
    end

    it "devolve nil para CNS inválido" do
      assert_nil subject.format("898000000000437")
    end
  end

  describe ".strip" do
    it "tira espaços, pontos e hífens" do
      assert_equal "898000000000436", subject.strip(" 898 0000.0000-0436 ")
    end

    it "devolve texto vazio para nil" do
      assert_equal "", subject.strip(nil)
    end
  end

  describe "entradas copiadas ou corrompidas" do
    it "aceita espaço não separável entre os grupos" do
      assert subject.valid?("898\u00A00000\u00A00000\u00A00436")
    end

    it "recusa texto com bytes inválidos sem levantar erro" do
      refute subject.valid?("898000000000436\xFF".dup.force_encoding(Encoding::UTF_8))
    end
  end
end
