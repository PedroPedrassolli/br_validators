# frozen_string_literal: true

require "test_helper"

# CNPJs fictícios, gerados só para os testes. O 12.ABC.345/01DE-35 é o exemplo
# do manual da Receita Federal.
describe BrValidators::CNPJ do
  subject { BrValidators::CNPJ }

  describe ".valid?" do
    it "aceita CNPJ numérico com e sem máscara" do
      assert subject.valid?("11.222.333/0001-81")
      assert subject.valid?("11222333000181")
      assert subject.valid?("98.765.432/0001-98")
    end

    it "aceita CNPJ alfanumérico com e sem máscara" do
      assert subject.valid?("12.ABC.345/01DE-35")
      assert subject.valid?("12ABC34501DE35")
      assert subject.valid?("A1.B2C.3D4/0001-93")
    end

    it "aceita letras minúsculas" do
      assert subject.valid?("12.abc.345/01de-35")
    end

    it "aceita CNPJ que começa com zeros ou só tem letras na raiz" do
      assert subject.valid?("00.000.000/0001-91")
      assert subject.valid?("ZZ.000.000/0000-78")
    end

    it "ignora espaços no começo, no fim e no meio" do
      assert subject.valid?("  11.222.333/0001-81 ")
      assert subject.valid?("11 222 333 0001 81")
    end

    it "recusa dígitos verificadores errados" do
      refute subject.valid?("11.222.333/0001-80")
      refute subject.valid?("12.ABC.345/01DE-53")
    end

    it "recusa letra nos dígitos verificadores" do
      refute subject.valid?("12.ABC.345/01DE-3A")
    end

    it "recusa CNPJ com todos os caracteres iguais" do
      refute subject.valid?("00.000.000/0000-00")
      refute subject.valid?("11111111111111")
    end

    it "recusa tamanho errado" do
      refute subject.valid?("1122233300018")
      refute subject.valid?("112223330001811")
    end

    it "recusa letras fora do ASCII que o Unicode passaria para maiúsculas" do
      # Válidos com letras ASCII...
      assert subject.valid?("12ABCI3450DE60")
      assert subject.valid?("12SS34ABCD0193")
      # ...mas "ı" (i sem ponto), "ſ" (s longo) e "ß" não são letras de CNPJ.
      refute subject.valid?("12abcı3450de60")
      refute subject.valid?("12ſS34ABCD0193")
      refute subject.valid?("12ß34ABCD0193")
    end

    it "aceita espaço não separável e recusa bytes inválidos sem levantar erro" do
      assert subject.valid?("12.ABC.345/01DE-35\u00A0")
      refute subject.valid?("12ABC34501DE35\xFF".dup.force_encoding(Encoding::UTF_8))
    end

    it "recusa outros símbolos, vazio e nil" do
      refute subject.valid?("11.222.333*0001-81")
      refute subject.valid?("")
      refute subject.valid?(nil)
    end
  end

  describe ".format" do
    it "coloca a máscara em um CNPJ numérico" do
      assert_equal "11.222.333/0001-81", subject.format("11222333000181")
    end

    it "coloca a máscara em um CNPJ alfanumérico, em maiúsculas" do
      assert_equal "12.ABC.345/01DE-35", subject.format("12abc34501de35")
    end

    it "devolve nil para CNPJ inválido" do
      assert_nil subject.format("11222333000180")
    end
  end

  describe ".strip" do
    it "tira pontos, barra, hífen e espaços" do
      assert_equal "11222333000181", subject.strip(" 11.222.333/0001-81 ")
    end

    it "passa as letras para maiúsculas" do
      assert_equal "12ABC34501DE35", subject.strip("12.abc.345/01de-35")
    end

    it "devolve texto vazio para nil" do
      assert_equal "", subject.strip(nil)
    end
  end
end
