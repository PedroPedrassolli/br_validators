# frozen_string_literal: true

require "test_helper"

# CPFs fictícios, gerados só para os testes.
describe BrValidators::CPF do
  subject { BrValidators::CPF }

  describe ".valid?" do
    it "aceita CPF com e sem máscara" do
      assert subject.valid?("123.456.789-09")
      assert subject.valid?("12345678909")
      assert subject.valid?("987.654.321-00")
    end

    it "aceita CPF que começa com zeros" do
      assert subject.valid?("000.000.019-10")
    end

    it "ignora espaços no começo, no fim e no meio" do
      assert subject.valid?("  300.200.100-79 ")
      assert subject.valid?("300 200 100 79")
    end

    it "recusa dígitos verificadores errados" do
      refute subject.valid?("123.456.789-00")
      refute subject.valid?("123.456.789-19")
    end

    it "recusa CPF com todos os dígitos iguais" do
      refute subject.valid?("111.111.111-11")
      refute subject.valid?("00000000000")
    end

    it "recusa tamanho errado" do
      refute subject.valid?("1234567890")
      refute subject.valid?("123456789091")
    end

    it "recusa letras e outros símbolos" do
      refute subject.valid?("123.456.789-0A")
      refute subject.valid?("123/456/789-09")
    end

    it "recusa vazio e nil" do
      refute subject.valid?("")
      refute subject.valid?(nil)
    end
  end

  describe ".format" do
    it "coloca a máscara em um CPF válido" do
      assert_equal "123.456.789-09", subject.format("12345678909")
    end

    it "mantém um CPF que já está formatado" do
      assert_equal "000.000.019-10", subject.format(" 000.000.019-10 ")
    end

    it "devolve nil para CPF inválido" do
      assert_nil subject.format("12345678900")
    end
  end

  describe ".strip" do
    it "tira pontos, hífen e espaços" do
      assert_equal "12345678909", subject.strip(" 123.456.789-09 ")
    end

    it "não tira letras, para que valid? possa recusar" do
      assert_equal "1234567890A", subject.strip("123.456.789-0A")
    end

    it "devolve texto vazio para nil" do
      assert_equal "", subject.strip(nil)
    end
  end

  # Texto copiado de PDF ou de site costuma trazer espaço não separável (U+00A0),
  # e texto corrompido pode ter bytes que não são UTF-8 válido.
  describe "entradas copiadas ou corrompidas" do
    it "aceita espaço não separável e outros espaços Unicode" do
      assert subject.valid?("123.456.789-09\u00A0")
      assert subject.valid?("123\u2007456\u2007789\u200709")
      assert_equal "12345678909", subject.strip("\u00A0123.456.789-09\u3000")
    end

    it "recusa texto com bytes inválidos sem levantar erro" do
      texto = "123.456.789-09\xFF".dup.force_encoding(Encoding::UTF_8)
      refute subject.valid?(texto)
      assert_nil subject.format(texto)
    end
  end
end
