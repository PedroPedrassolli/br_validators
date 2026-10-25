// Funções da página que não mexem no HTML, para dar para testar com node --test.

// Exemplos fictícios, os mesmos usados nos testes da gem.
export const EXEMPLOS = {
  cpf: "123.456.789-09",
  cnpj: "12.ABC.345/01DE-35",
  cns: "898 0000 0000 0436",
  pix: "+5511987654321",
  boleto: "00190.00009 02345.678904 12345.678176 1 10000000012345",
};

// Nomes em português para os tipos que a API devolve.
const TIPOS = {
  cpf: "chave de CPF",
  cnpj: "chave de CNPJ",
  phone: "chave de celular",
  email: "chave de e-mail",
  evp: "chave aleatória",
  cobranca: "boleto de cobrança",
  arrecadacao: "boleto de arrecadação",
};

// Endereço da função Ruby que valida (api/validar.rb).
export function urlDaValidacao(documento, valor) {
  const params = new URLSearchParams({ documento, valor: valor.trim() });
  return `/api/validar?${params}`;
}

// Transforma a resposta da API no que a página mostra.
export function descrever(resposta) {
  if (resposta.erro) {
    return { titulo: "Não deu para validar", detalhes: [resposta.erro], valido: false };
  }

  const detalhes = [];
  if (resposta.formatado) detalhes.push(`Formatado: ${resposta.formatado}`);
  if (resposta.tipo) detalhes.push(`Tipo: ${TIPOS[resposta.tipo] ?? resposta.tipo}`);

  return { titulo: resposta.valido ? "Válido" : "Inválido", detalhes, valido: resposta.valido };
}
