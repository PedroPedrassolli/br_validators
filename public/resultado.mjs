// Funções da página que não mexem no HTML, para dar para testar com node --test.

// Tudo o que a página precisa saber de cada documento, na ordem dos botões:
// - exemplo: fictício, o mesmo usado nos testes da gem;
// - nome e feminino: para escrever "CPF válido" ou "Placa válida";
// - rotulo e dica: o que aparece em cima e embaixo do campo;
// - teclado: "numeric" abre o teclado de números no celular, "tel" o de telefone
//   (com + e parênteses) e "text" o com letras (CNPJ alfanumérico, placa, e-mail);
// - modulo e metodos: o módulo da gem e os métodos que o trecho de código mostra;
// - tamanhos e tamanhoCerto: quantos caracteres o documento tem sem a máscara
//   (null quando varia, como na chave Pix e no telefone com ou sem +55);
// - regra: o que mais precisa estar certo quando o tamanho já está.
export const DOCUMENTOS = {
  cpf: {
    exemplo: "123.456.789-09",
    nome: "CPF",
    rotulo: "Número do CPF",
    dica: "11 dígitos, com ou sem pontos e hífen.",
    teclado: "numeric",
    modulo: "CPF",
    metodos: ["format"],
    tamanhos: [11],
    tamanhoCerto: "O CPF tem 11",
    regra: "Só números, e os dois últimos (verificadores) precisam bater com os outros nove. Todos iguais não vale.",
  },
  cnpj: {
    exemplo: "12.ABC.345/01DE-35",
    nome: "CNPJ",
    rotulo: "Número do CNPJ",
    dica: "14 caracteres; os 12 primeiros podem ter letras (CNPJ alfanumérico).",
    teclado: "text",
    modulo: "CNPJ",
    metodos: ["format"],
    tamanhos: [14],
    tamanhoCerto: "O CNPJ tem 14",
    regra: "Os dois últimos são verificadores e precisam bater com os 12 primeiros.",
  },
  cns: {
    exemplo: "898 0000 0000 0436",
    nome: "CNS",
    rotulo: "Número do Cartão Nacional de Saúde",
    dica: "15 dígitos, com ou sem espaços.",
    teclado: "numeric",
    modulo: "CNS",
    metodos: ["format"],
    tamanhos: [15],
    tamanhoCerto: "O CNS tem 15",
    regra: "Começa com 1, 2, 7, 8 ou 9 e precisa passar na conta de verificação do Ministério da Saúde.",
  },
  titulo_eleitor: {
    exemplo: "1023 8501 0671",
    nome: "Título de eleitor",
    rotulo: "Número do título de eleitor",
    dica: "12 dígitos, com ou sem espaços.",
    teclado: "numeric",
    modulo: "TituloEleitor",
    metodos: ["format", "uf"],
    tamanhos: [12],
    tamanhoCerto: "O título tem 12",
    regra: "O 9º e o 10º dígitos são a UF (de 01 a 28) e os dois últimos são verificadores.",
  },
  pix: {
    exemplo: "+5511987654321",
    nome: "Chave Pix",
    feminino: true,
    rotulo: "Chave Pix",
    dica: "Como o banco guarda: CPF ou CNPJ sem pontos, celular com +55 e DDD, e-mail em minúsculas ou chave aleatória.",
    teclado: "text",
    modulo: "Pix",
    metodos: ["type"],
    tamanhos: null,
    regra:
      "Não é nenhum tipo de chave: CPF ou CNPJ só com números, celular com +55 e DDD, e-mail em minúsculas ou chave aleatória.",
  },
  boleto: {
    exemplo: "00190.00009 02345.678904 12345.678176 1 10000000012345",
    nome: "Boleto",
    rotulo: "Linha digitável do boleto",
    dica: "47 dígitos (cobrança) ou 48 (contas e tributos), com ou sem pontos e espaços.",
    teclado: "numeric",
    modulo: "Boleto",
    metodos: ["format", "type"],
    tamanhos: [47, 48],
    tamanhoCerto: "A linha digitável tem 47 (cobrança) ou 48 (contas e tributos)",
    regra: "Cada bloco da linha tem um dígito verificador: confira se nenhum número foi trocado.",
  },
  cep: {
    exemplo: "01001-000",
    nome: "CEP",
    rotulo: "CEP",
    dica: "8 dígitos, com ou sem hífen. Confere só o formato: o CEP não tem dígito verificador.",
    teclado: "numeric",
    modulo: "CEP",
    metodos: ["format"],
    tamanhos: [8],
    tamanhoCerto: "O CEP tem 8",
    regra: "Só números, e 00000-000 não vale.",
  },
  telefone: {
    exemplo: "(11) 98765-4321",
    nome: "Telefone",
    rotulo: "Telefone com DDD",
    dica: "DDD e número, fixo ou celular, com ou sem +55, parênteses e hífen.",
    teclado: "tel",
    modulo: "Telefone",
    metodos: ["format", "type", "ddd"],
    tamanhos: null,
    regra:
      "Precisa de um DDD que existe e de um número de fixo (8 dígitos, começando de 2 a 5) ou de celular (9 dígitos, começando com 9).",
  },
  placa: {
    exemplo: "ABC-1234",
    nome: "Placa",
    feminino: true,
    rotulo: "Placa",
    dica: "Antiga (ABC-1234) ou Mercosul (ABC1D23).",
    teclado: "text",
    modulo: "Placa",
    metodos: ["format", "type"],
    tamanhos: [7],
    tamanhoCerto: "A placa tem 7",
    regra: "Três letras e quatro números (ABC1234) ou o padrão Mercosul, com uma letra na 5ª posição (ABC1D23).",
  },
  renavam: {
    exemplo: "00123456789",
    nome: "RENAVAM",
    rotulo: "Código RENAVAM",
    dica: "11 dígitos. Os antigos, de 9, ganham dois zeros na frente.",
    teclado: "numeric",
    modulo: "RENAVAM",
    metodos: ["format"],
    tamanhos: [11],
    tamanhoCerto: "O RENAVAM tem 11",
    regra: "Só números, e o último (verificador) precisa bater com os outros dez. Todos iguais não vale.",
  },
  chave_acesso: {
    exemplo: "3526 1011 2223 3300 0181 5500 1000 0001 2311 2345 6783",
    nome: "Chave de acesso",
    feminino: true,
    rotulo: "Chave de acesso da nota fiscal",
    dica: "Os 44 caracteres impressos na NF-e, NFC-e, CT-e ou MDF-e, com ou sem espaços.",
    teclado: "text",
    modulo: "ChaveAcesso",
    metodos: ["format", "modelo"],
    tamanhos: [44],
    tamanhoCerto: "A chave de acesso tem 44",
    regra: "O último dígito é verificador, e a chave também precisa ter uma UF e um mês de emissão que existem.",
  },
  processo_cnj: {
    exemplo: "0000123-37.2024.8.26.9999",
    nome: "Processo",
    rotulo: "Número do processo",
    dica: "Numeração única do CNJ: 0000000-00.0000.0.00.0000, com ou sem pontos.",
    teclado: "numeric",
    modulo: "ProcessoCNJ",
    metodos: ["format", "segmento"],
    tamanhos: [20],
    tamanhoCerto: "O número do processo tem 20",
    regra:
      "Os dois dígitos depois do hífen são verificadores, e o 14º dígito precisa ser um ramo da Justiça (de 1 a 9).",
  },
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

// Rótulo do "detalhe" que a API devolve para alguns documentos.
const DETALHES = {
  telefone: "DDD",
  titulo_eleitor: "UF de emissão",
  processo_cnj: "Ramo da Justiça",
  chave_acesso: "Modelo",
};

// Nome dos modelos mais comuns de documento fiscal (o código vem na chave de acesso).
const MODELOS = { 55: "NF-e", 65: "NFC-e", 57: "CT-e", 67: "CT-e OS", 58: "MDF-e" };

// Endereço da função Ruby que valida (api/validar.rb).
export function urlDaValidacao(documento, valor) {
  const params = new URLSearchParams({ documento, valor: valor.trim() });
  return `/api/validar?${params}`;
}

// Explica por que o documento é inválido: primeiro o tamanho, que é o erro mais
// comum (faltou ou sobrou um dígito); com o tamanho certo, o que mais é conferido.
export function motivo(documento, caracteres) {
  const { tamanhos, tamanhoCerto, regra } = DOCUMENTOS[documento];
  if (!tamanhos || caracteres == null || tamanhos.includes(caracteres)) return regra;
  if (caracteres === 0) return "Não sobrou nenhum caractere depois de tirar pontos, traços e espaços.";

  const contagem = caracteres === 1 ? "1 caractere" : `${caracteres} caracteres`;
  return `Tem ${contagem}, sem contar pontos, traços e espaços. ${tamanhoCerto}.`;
}

// Transforma a resposta da API no que a página mostra:
// { estado: "valido" | "invalido" | "erro", titulo, dados: [[rótulo, valor]], motivo }.
export function descrever(resposta) {
  if (resposta.erro) {
    return { estado: "erro", titulo: "Não deu para validar", dados: [], motivo: resposta.erro };
  }

  const documento = DOCUMENTOS[resposta.documento];
  const adjetivo = (valido) => (documento.feminino ? `${valido}a` : `${valido}o`);

  if (!resposta.valido) {
    return {
      estado: "invalido",
      titulo: `${documento.nome} ${adjetivo("inválid")}`,
      dados: [],
      motivo: motivo(resposta.documento, resposta.caracteres),
    };
  }

  const dados = [];
  if (resposta.formatado) dados.push(["Formatado", resposta.formatado]);
  if (resposta.tipo) dados.push(["Tipo", TIPOS[resposta.tipo] ?? resposta.tipo]);
  if (resposta.detalhe) {
    const valor =
      resposta.documento === "chave_acesso" && MODELOS[resposta.detalhe]
        ? `${MODELOS[resposta.detalhe]} (${resposta.detalhe})`
        : resposta.detalhe;
    dados.push([DETALHES[resposta.documento] ?? "Detalhe", valor]);
  }

  return { estado: "valido", titulo: `${documento.nome} ${adjetivo("válid")}`, dados, motivo: null };
}

// Texto Ruby entre aspas duplas: escapa a barra, as aspas e o "#{" da interpolação.
export function textoRuby(valor) {
  return `"${valor.replaceAll("\\", "\\\\").replaceAll('"', '\\"').replaceAll("#{", "\\#{")}"`;
}

// Campo da resposta da API que traz o retorno de cada método. Os métodos a mais
// (uf, ddd, segmento, modelo) vêm todos no "detalhe".
const RETORNOS = { "valid?": "valido", format: "formatado", type: "tipo" };

// O que o método devolveu, escrito como o Ruby mostraria (true, nil, :celular, "PR").
function retornoRuby(metodo, resposta) {
  const valor = resposta[RETORNOS[metodo] ?? "detalhe"];
  if (valor == null) return "nil";
  if (typeof valor === "boolean") return String(valor);
  return metodo === "type" ? `:${valor}` : textoRuby(valor);
}

// Linhas do trecho de código Ruby que faz o mesmo que a página. O valor vai numa
// variável com o nome do documento, para as chamadas caberem na tela do celular.
// Depois de validar, cada chamada ganha embaixo a linha "# => o que devolveu".
export function trechoRuby(documento, valor, resposta = null) {
  const { modulo, metodos } = DOCUMENTOS[documento];
  const linhas = ['require "br_validators"', "", `${documento} = ${textoRuby(valor.trim())}`, ""];
  for (const metodo of ["valid?", ...metodos]) {
    linhas.push(`BrValidators::${modulo}.${metodo}(${documento})`);
    if (resposta) linhas.push(`# => ${retornoRuby(metodo, resposta)}`);
  }
  return linhas;
}
