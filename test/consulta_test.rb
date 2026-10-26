# frozen_string_literal: true

require "test_helper"
require "socket"
require "br_validators/consulta"

# Nenhum teste chama a internet: as consultas usam um cliente falso, e o cliente
# HTTP de verdade conversa com um servidor de mentira na própria máquina.
describe BrValidators::Consulta do
  subject { BrValidators::Consulta }

  # Responde sempre o mesmo [status, corpo] e guarda os endereços pedidos.
  let(:cliente) do
    Class.new do
      attr_reader :pedidos

      def initialize(status, corpo)
        @status = status
        @corpo = corpo
        @pedidos = []
      end

      def get(uri)
        @pedidos << uri.to_s
        [@status, @corpo]
      end
    end
  end

  def responder(status, corpo = "{}")
    falso = cliente.new(status, corpo)
    subject.cliente = falso
    falso
  end

  after { subject.cliente = nil }

  describe ".cep" do
    it "consulta o CEP sem máscara e devolve o JSON como Hash" do
      falso = responder(200, '{"cep":"01001000","state":"SP","city":"São Paulo"}')
      assert_equal({ "cep" => "01001000", "state" => "SP", "city" => "São Paulo" }, subject.cep("01001-000"))
      assert_equal ["https://brasilapi.com.br/api/cep/v1/01001000"], falso.pedidos
    end

    it "devolve nil para CEP inválido, sem chamar a internet" do
      falso = responder(200)
      assert_nil subject.cep("123")
      assert_empty falso.pedidos
    end

    it "devolve nil quando a BrasilAPI não acha o CEP" do
      responder(404, '{"message":"CEP não encontrado"}')
      assert_nil subject.cep("99999-999")
    end
  end

  describe ".cnpj" do
    it "consulta o CNPJ sem máscara" do
      falso = responder(200, '{"razao_social":"EMPRESA DE TESTE"}')
      assert_equal "EMPRESA DE TESTE", subject.cnpj("11.222.333/0001-81")["razao_social"]
      assert_equal ["https://brasilapi.com.br/api/cnpj/v1/11222333000181"], falso.pedidos
    end

    it "devolve nil para CNPJ inválido e quando a BrasilAPI recusa" do
      responder(400)
      assert_nil subject.cnpj("11.222.333/0001-80")
      assert_nil subject.cnpj("11.222.333/0001-81")
    end
  end

  describe ".banco" do
    it "aceita o código com ou sem zeros à esquerda" do
      falso = responder(200, '{"code":1,"name":"BCO DO BRASIL S.A."}')
      assert_equal 1, subject.banco("001")["code"]
      subject.banco(1)
      assert_equal ["https://brasilapi.com.br/api/banks/v1/1"] * 2, falso.pedidos
    end

    it "devolve nil para código que não é número de até 3 dígitos" do
      falso = responder(200)
      assert_nil subject.banco("abc")
      assert_nil subject.banco("1234")
      assert_nil subject.banco(nil)
      assert_empty falso.pedidos
    end
  end

  describe ".ddd" do
    it "consulta só DDDs que existem" do
      falso = responder(200, '{"state":"SP","cities":["SÃO PAULO"]}')
      assert_equal "SP", subject.ddd("11")["state"]
      assert_nil subject.ddd("20")
      assert_equal ["https://brasilapi.com.br/api/ddd/v1/11"], falso.pedidos
    end
  end

  describe "erros" do
    it "levanta Consulta::Erro quando a BrasilAPI responde com erro" do
      responder(503, '{"message":"indisponível"}')
      erro = assert_raises(BrValidators::Consulta::Erro) { subject.cep("01001-000") }
      assert_match(/503/, erro.message)
    end

    it "levanta Consulta::Erro quando a resposta não é JSON" do
      responder(200, "<html>manutenção</html>")
      assert_raises(BrValidators::Consulta::Erro) { subject.cep("01001-000") }
    end
  end

  describe "cliente padrão" do
    it "é o HTTP da própria gem" do
      assert_equal BrValidators::Consulta::HTTP, subject.cliente
    end
  end
end

describe BrValidators::Consulta::HTTP do
  subject { BrValidators::Consulta::HTTP }

  # Servidor de mentira: aceita uma conexão, lê o pedido e devolve uma resposta fixa.
  def servidor_local(resposta)
    servidor = TCPServer.new("127.0.0.1", 0)
    pedido = Queue.new
    Thread.new do
      conexao = servidor.accept
      linhas = []
      while (linha = conexao.gets) && linha != "\r\n"
        linhas << linha
      end
      pedido << linhas
      conexao.write(resposta)
      conexao.close
      servidor.close
    end
    [servidor.addr[1], pedido]
  end

  it "faz o GET e devolve o status e o corpo" do
    porta, pedido = servidor_local("HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: 11\r\n" \
                                   "Connection: close\r\n\r\n{\"ok\":true}")
    status, corpo = subject.get(URI("http://127.0.0.1:#{porta}/api/cep/v1/01001000"))
    assert_equal 200, status
    assert_equal '{"ok":true}', corpo
    linhas = pedido.pop
    assert_equal "GET /api/cep/v1/01001000 HTTP/1.1\r\n", linhas.first
    assert(linhas.any? { |linha| linha.start_with?("User-Agent: br_validators/") })
  end

  it "transforma falha de conexão em Consulta::Erro" do
    servidor = TCPServer.new("127.0.0.1", 0)
    porta = servidor.addr[1]
    servidor.close
    assert_raises(BrValidators::Consulta::Erro) { subject.get(URI("http://127.0.0.1:#{porta}/")) }
  end
end
