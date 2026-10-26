# frozen_string_literal: true

require "test_helper"

# Chaves fictícias: emitente com o CNPJ de exemplo 11.222.333/0001-81 ou com o
# CNPJ alfanumérico do manual da Receita (12.ABC.345/01DE-35).
describe BrValidators::ChaveAcesso do
  subject { BrValidators::ChaveAcesso }

  let(:numerica) { "35261011222333000181550010000001231123456783" }
  let(:alfanumerica) { "35261012ABC34501DE35550010000001231123456784" }

  describe ".valid?" do
    it "aceita chave com CNPJ numérico, com e sem espaços" do
      assert subject.valid?(numerica)
      assert subject.valid?(numerica.scan(/.{4}/).join(" "))
    end

    it "aceita chave com CNPJ alfanumérico, também em minúsculas" do
      assert subject.valid?(alfanumerica)
      assert subject.valid?(alfanumerica.downcase)
    end

    it "recusa dígito verificador errado" do
      refute subject.valid?(numerica.sub(/3\z/, "4"))
      refute subject.valid?(alfanumerica.sub(/4\z/, "5"))
    end

    it "recusa letra fora do CNPJ e tamanho errado" do
      refute subject.valid?("A5261011222333000181550010000001231123456783")
      refute subject.valid?("35261011222333000181A50010000001231123456783")
      refute subject.valid?(numerica[0, 43])
      refute subject.valid?("#{numerica}0")
    end

    it "recusa vazio, nil e bytes inválidos sem levantar erro" do
      refute subject.valid?("")
      refute subject.valid?(nil)
      refute subject.valid?("#{numerica}\xFF".force_encoding(Encoding::UTF_8))
    end
  end

  describe ".format" do
    it "agrupa de 4 em 4" do
      assert_equal "3526 1011 2223 3300 0181 5500 1000 0001 2311 2345 6783", subject.format(numerica)
    end

    it "devolve nil para chave inválida" do
      assert_nil subject.format("123")
    end
  end

  describe ".modelo" do
    it "devolve o código do modelo do documento" do
      assert_equal "55", subject.modelo(numerica)
    end

    it "devolve nil para chave inválida" do
      assert_nil subject.modelo("123")
    end
  end

  describe ".strip" do
    it "tira os espaços e passa as letras para maiúsculas" do
      assert_equal alfanumerica, subject.strip(alfanumerica.downcase.scan(/.{4}/).join(" "))
    end
  end
end
