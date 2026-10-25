# frozen_string_literal: true

require "json"
require_relative "../lib/br_validators"

# Função da Vercel que a página de teste chama. Usa a própria gem, então as
# regras de validação ficam num lugar só.
#
#   GET /api/validar?documento=cpf&valor=123.456.789-09
#   => {"documento":"cpf","valido":true,"formatado":"123.456.789-09","tipo":null}
#
# "tipo" só aparece preenchido para chave Pix (:cpf, :email...) e boleto
# (:cobranca ou :arrecadacao).
module ValidarApi
  DOCUMENTOS = {
    "cpf" => BrValidators::CPF,
    "cnpj" => BrValidators::CNPJ,
    "cns" => BrValidators::CNS,
    "pix" => BrValidators::Pix,
    "boleto" => BrValidators::Boleto
  }.freeze

  # Nenhum documento tem mais que isso; recusa textos enormes logo de cara.
  TAMANHO_MAXIMO = 100

  # O servidor da Vercel (WEBrick) entrega os parâmetros da URL como bytes, sem
  # encoding. Marcar como UTF-8 deixa a gem reconhecer os espaços Unicode, como o
  # espaço não separável que vem junto ao copiar um boleto de um PDF.
  def self.parametro(valor)
    valor.to_s.dup.force_encoding(Encoding::UTF_8)
  end

  # Devolve [status HTTP, corpo da resposta].
  def self.responder(documento, valor)
    modulo = DOCUMENTOS[documento.to_s]
    return [400, { erro: "documento deve ser um destes: #{DOCUMENTOS.keys.join(', ')}" }] unless modulo
    return [400, { erro: "valor muito longo" }] if valor.to_s.size > TAMANHO_MAXIMO

    [200, resultado(documento, modulo, valor.to_s)]
  end

  def self.resultado(documento, modulo, valor)
    {
      documento: documento,
      valido: modulo.valid?(valor),
      formatado: modulo.respond_to?(:format) ? modulo.format(valor) : nil,
      tipo: modulo.respond_to?(:type) ? modulo.type(valor) : nil
    }
  end
end

# Formato que o runtime Ruby da Vercel espera: um Proc chamado Handler.
Handler = proc do |request, response|
  documento = ValidarApi.parametro(request.query["documento"])
  valor = ValidarApi.parametro(request.query["valor"])
  status, corpo = ValidarApi.responder(documento, valor)
  response.status = status
  response["Content-Type"] = "application/json; charset=utf-8"
  # A resposta só depende da URL: a Vercel pode guardar em cache e responder
  # sem rodar a função de novo (economiza execuções no plano gratuito).
  response["Cache-Control"] = "public, max-age=0, s-maxage=86400" if status == 200
  response.body = JSON.generate(corpo)
end
