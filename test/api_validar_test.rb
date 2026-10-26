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
    assert_equal({ "documento" => "cpf", "valido" => true, "formatado" => "123.456.789-09", "tipo" => nil,
                   "detalhe" => nil }, subject)
    assert_equal 200, response.status
  end

  it "devolve o tipo da chave Pix, sem formatado" do
    query.merge!("documento" => "pix", "valor" => "+5511987654321")
    assert_equal({ "documento" => "pix", "valido" => true, "formatado" => nil, "tipo" => "phone", "detalhe" => nil },
                 subject)
  end

  it "devolve o tipo do boleto" do
    query.merge!("documento" => "boleto", "valor" => "826700000019000000000000000000000000000000000000")
    assert_equal "arrecadacao", subject["tipo"]
  end

  it "valida os documentos novos, com o tipo do telefone e da placa" do
    query.merge!("documento" => "telefone", "valor" => "+55 11 98765-4321")
    assert_equal({ "documento" => "telefone", "valido" => true, "formatado" => "(11) 98765-4321",
                   "tipo" => "celular", "detalhe" => "11" }, subject)
  end

  it "devolve o detalhe do título, do processo e da chave de acesso" do
    query.merge!("documento" => "titulo_eleitor", "valor" => "1023 8501 0671")
    assert_equal "PR", subject["detalhe"]
  end

  it "devolve o modelo da chave de acesso como detalhe" do
    query.merge!("documento" => "chave_acesso", "valor" => "35261011222333000181550010000001231123456783")
    assert_equal "55", subject["detalhe"]
  end

  it "não devolve detalhe quando o documento é inválido" do
    query.merge!("documento" => "processo_cnj", "valor" => "0000123-38.2024.8.26.9999")
    assert_nil subject["detalhe"]
  end

  it "aceita traço tipográfico copiado de um documento" do
    query["valor"] = "123.456.789\u201309"
    assert subject["valido"]
  end

  it "devolve o tipo da placa" do
    query.merge!("documento" => "placa", "valor" => "abc-1234")
    assert_equal "antiga", subject["tipo"]
    assert_equal "ABC-1234", subject["formatado"]
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
    assert_match(/cpf, cnpj, cns, pix, boleto, cep, telefone/, subject["erro"])
    assert_equal 400, response.status
    assert_nil response["Cache-Control"]
  end

  it "recusa valor muito longo" do
    query["valor"] = "1" * 101
    assert_equal "valor muito longo", subject["erro"]
  end

  # O WEBrick da Vercel entrega os parâmetros como bytes (encoding binário).
  it "aceita a linha de boleto copiada com espaço não separável" do
    linha = "00190.00009\u00A002345.678904 12345.678176 1 10000000012345"
    query.merge!("documento" => "boleto".b, "valor" => linha.b)
    assert subject["valido"]
    assert_equal "cobranca", subject["tipo"]
  end

  it "responde inválido, sem erro, quando o valor tem bytes inválidos" do
    query["valor"] = "123\xFF\xFE".b
    refute subject["valido"]
    assert_equal 200, response.status
  end

  it "trata parâmetros ausentes" do
    query.clear
    subject
    assert_equal 400, response.status
  end
end
