# frozen_string_literal: true

require "json"
require "net/http"
require "openssl"
# Só os documentos (para validar antes de consultar), sem os validadores do Rails.
require_relative "documentos"

module BrValidators
  # Consultas online pela BrasilAPI (https://brasilapi.com.br), um serviço gratuito,
  # de código aberto e sem chave de acesso. É opcional: não vem com o
  # require "br_validators" (a validação continua sem rede); carregue com
  #
  #   require "br_validators/consulta"
  #
  #   BrValidators::Consulta.cep("01001-000")
  #   # => {"cep"=>"01001000", "state"=>"SP", "city"=>"São Paulo", "street"=>..., ...}
  #   BrValidators::Consulta.cnpj("11.222.333/0001-81")  # dados da Receita Federal
  #   BrValidators::Consulta.banco("001")                # => {"code"=>1, "name"=>"BCO DO BRASIL S.A.", ...}
  #   BrValidators::Consulta.ddd("11")                   # => {"state"=>"SP", "cities"=>[...]}
  #
  # Cada método:
  #   - valida o dado antes (documento inválido devolve nil sem chamar a internet);
  #   - devolve o JSON da BrasilAPI como Hash (chaves em texto), ou nil se não achar;
  #   - levanta BrValidators::Consulta::Erro se a BrasilAPI não responder ou der erro.
  module Consulta
    BASE = "https://brasilapi.com.br/api"

    # Segundos de espera para conectar e para receber a resposta.
    TIMEOUT = 5

    # A BrasilAPI não respondeu, demorou demais ou respondeu com erro.
    class Erro < StandardError; end

    class << self
      # Quem faz a requisição: qualquer objeto com get(uri) que devolva
      # [status, corpo]. O padrão é o HTTP abaixo; os testes trocam por um falso,
      # e quem usa a gem pode trocar por um com cache, por exemplo.
      attr_writer :cliente

      def cliente
        @cliente ||= HTTP
      end
    end

    # Endereço do CEP: cep, state, city, neighborhood, street e service.
    def self.cep(valor)
      return nil unless CEP.valid?(valor)

      buscar("/cep/v1/#{CEP.strip(valor)}")
    end

    # Dados do CNPJ na Receita Federal (razao_social, nome_fantasia,
    # descricao_situacao_cadastral, uf, municipio...). O CNPJ alfanumérico só é
    # encontrado quando a BrasilAPI passar a aceitá-lo.
    def self.cnpj(valor)
      return nil unless CNPJ.valid?(valor)

      buscar("/cnpj/v1/#{CNPJ.strip(valor)}")
    end

    # Banco pelo código de compensação ("001", "237", 341): code, name, fullName e ispb.
    def self.banco(codigo)
      # BrValidators.texto: aceita número e texto em qualquer encoding (UTF-16 dava erro).
      codigo = BrValidators.texto(codigo).strip
      return nil unless codigo.match?(/\A\d{1,3}\z/)

      buscar("/banks/v1/#{codigo.to_i}")
    end

    # UF e cidades de um DDD: state e cities.
    def self.ddd(valor)
      ddd = BrValidators.texto(valor).strip
      return nil unless Telefone::DDDS.include?(ddd)

      buscar("/ddd/v1/#{ddd}")
    end

    # 200 vira Hash; 400 e 404 (não achou) viram nil; o resto é erro.
    def self.buscar(caminho)
      status, corpo = cliente.get(URI("#{BASE}#{caminho}"))
      case status
      when 200 then JSON.parse(corpo)
      when 400, 404 then nil
      else raise Erro, "A BrasilAPI respondeu #{status} em #{caminho}."
      end
    rescue JSON::ParserError
      raise Erro, "A BrasilAPI respondeu algo que não é JSON em #{caminho}."
    end

    private_class_method :buscar

    # Cliente padrão, só com a biblioteca padrão do Ruby (Net::HTTP).
    module HTTP
      HEADERS = { "Accept" => "application/json", "User-Agent" => "br_validators/#{VERSION}" }.freeze

      # Problemas de rede: não conectou, a conexão caiu, demorou demais, o
      # certificado falhou ou a resposta veio quebrada (não é HTTP de verdade).
      # Viram Consulta::Erro, para quem chama tratar um erro só.
      ERROS_DE_REDE = [
        Timeout::Error, SocketError, SystemCallError, IOError, OpenSSL::SSL::SSLError,
        Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
      ].freeze

      def self.get(uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"
        http.open_timeout = TIMEOUT
        http.read_timeout = TIMEOUT
        resposta = http.get(uri.request_uri, HEADERS)
        [resposta.code.to_i, resposta.body]
      rescue *ERROS_DE_REDE => e
        raise Erro, "Não deu para falar com a BrasilAPI (#{e.class})."
      end
    end
  end
end
