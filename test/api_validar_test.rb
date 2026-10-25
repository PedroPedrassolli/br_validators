# frozen_string_literal: true

require "test_helper"
require_relative "../api/validar"

# Testa a função da Vercel sem servidor: o request e o response são objetos
# simples com os mesmos métodos que o runtime usa.
describe "api/validar.rb" do
  let(:query) { { "documento" => "cpf", "valor" => "12345678909" } }
  let(:request) { Struct.new(:query).new(query) }
  let(:response) do
    Class.new(Hash) { attr_accessor :status, :body }.new
  end

  subject do
    Handler.call(request, response)
    JSON.parse(response.body)
  end

  it "valida e formata um CPF" do
    assert_equal({ "documento" => "cpf", "valido" => true, "formatado" => "123.456.789-09", "tipo" => nil }, subject)
    assert_equal 200, response.status
  end

  it "devolve o tipo da chave Pix, sem formatado" do
    query.merge!("documento" => "pix", "valor" => "+5511987654321")
    assert_equal({ "documento" => "pix", "valido" => true, "formatado" => nil, "tipo" => "phone" }, subject)
  end

  it "devolve o tipo do boleto" do
    query.merge!("documento" => "boleto", "valor" => "826700000019000000000000000000000000000000000000")
    assert_equal "arrecadacao", subject["tipo"]
  end

  it "responde documento inválido com valido false" do
    query["valor"] = "111.111.111-11"
    refute subject["valido"]
    assert_nil subject["formatado"]
  end

  it "manda JSON e deixa a resposta válida em cache na Vercel" do
    subject
    assert_equal "application/json; charset=utf-8", response["Content-Type"]
    assert_equal "public, max-age=0, s-maxage=86400", response["Cache-Control"]
  end

  it "recusa documento desconhecido sem guardar em cache" do
    query["documento"] = "rg"
    assert_match(/cpf, cnpj, cns, pix, boleto/, subject["erro"])
    assert_equal 400, response.status
    assert_nil response["Cache-Control"]
  end

  it "recusa valor muito longo" do
    query["valor"] = "1" * 101
    assert_equal "valor muito longo", subject["erro"]
  end

  it "trata parâmetros ausentes" do
    query.clear
    subject
    assert_equal 400, response.status
  end
end
