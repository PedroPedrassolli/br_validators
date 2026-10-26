// Funções da página que não mexem no HTML, para dar para testar com node --test.

// Exemplos fictícios, os mesmos usados nos testes da gem.
export const EXEMPLOS = {
  cpf: "123.456.789-09",
  cnpj: "12.ABC.345/01DE-35",
  cns: "898 0000 0000 0436",
  pix: "+5511987654321",
  boleto: "00190.00009 02345.678904 12345.678176 1 10000000012345",
  titulo_eleitor: "1023 8501 0671",
  cep: "01001-000",
  telefone: "(11) 98765-4321",
  placa: "ABC-1234",
  renavam: "00123456789",
  chave_acesso: "3526 1011 2223 3300 0181 5500 1000 0001 2311 2345 6783",
  processo_cnj: "0000123-37.2024.8.26.9999",
};

// Dica que aparece embaixo do campo e teclado do celular para cada documento.
// "numeric" abre o teclado de números; "tel", o de telefone (com + e parênteses);
// "text", o teclado com letras (CNPJ alfanumérico, placa, e-mail da chave Pix).
export const CAMPOS = {
  cpf: { dica: "11 dígitos, com ou sem pontos e hífen.", teclado: "numeric" },
  cnpj: { dica: "14 caracteres; os 12 primeiros podem ter letras (CNPJ alfanumérico).", teclado: "text" },
  cns: { dica: "15 dígitos, com ou sem espaços.", teclado: "numeric" },
  pix: {
    dica: "Como o banco guarda: CPF ou CNPJ sem pontos, celular com +55 e DDD, e-mail em minúsculas ou chave aleatória.",
    teclado: "text",
  },
  boleto: {
    dica: "47 dígitos (cobrança) ou 48 (contas e tributos), com ou sem pontos e espaços.",
    teclado: "numeric",
  },
  titulo_eleitor: { dica: "12 dígitos, com ou sem espaços.", teclado: "numeric" },
  cep: {
    dica: "8 dígitos, com ou sem hífen. Confere só o formato: o CEP não tem dígito verificador.",
    teclado: "numeric",
  },
  telefone: { dica: "DDD e número, fixo ou celular, com ou sem +55, parênteses e hífen.", teclado: "tel" },
  placa: { dica: "Antiga (ABC-1234) ou Mercosul (ABC1D23).", teclado: "text" },
  renavam: { dica: "11 dígitos. Os antigos, de 9, ganham dois zeros na frente.", teclado: "numeric" },
  chave_acesso: { dica: "Os 44 caracteres da chave impressa na nota, com ou sem espaços.", teclado: "text" },
  processo_cnj: { dica: "Numeração única: 0000000-00.0000.0.00.0000, com ou sem pontos.", teclado: "numeric" },
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
  celular: "celular",
  fixo: "telefone fixo",
  antiga: "placa antiga",
  mercosul: "placa Mercosul",
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

  if (!resposta.valido) {
    return { titulo: "Inválido", detalhes: ["Confira o número e o formato indicado embaixo do campo."], valido: false };
  }

  const detalhes = [];
  if (resposta.formatado) detalhes.push(`Formatado: ${resposta.formatado}`);
  if (resposta.tipo) detalhes.push(`Tipo: ${TIPOS[resposta.tipo] ?? resposta.tipo}`);

  return { titulo: "Válido", detalhes, valido: true };
}
