// Testes das funções da página: node --test "test/js/*.test.mjs"
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { describe, it } from "node:test";

import {
  DOCUMENTOS,
  descrever,
  motivo,
  realce,
  textoRuby,
  trechoRuby,
  urlDaValidacao,
} from "../../public/resultado.mjs";

describe("urlDaValidacao", () => {
  it("monta a URL da API com os parâmetros codificados", () => {
    assert.equal(
      urlDaValidacao("cnpj", " 12.ABC.345/01DE-35 "),
      "/api/validar?documento=cnpj&valor=12.ABC.345%2F01DE-35",
    );
  });
});

describe("descrever", () => {
  it("mostra o documento formatado quando é válido", () => {
    const texto = descrever({ documento: "cpf", valido: true, formatado: "123.456.789-09", tipo: null });
    assert.deepEqual(texto, {
      estado: "valido",
      titulo: "CPF válido",
      dados: [["Formatado", "123.456.789-09"]],
      motivo: null,
    });
  });

  it("concorda o título com documentos femininos", () => {
    assert.equal(descrever({ documento: "placa", valido: true }).titulo, "Placa válida");
    assert.equal(descrever({ documento: "chave_acesso", valido: false }).titulo, "Chave de acesso inválida");
  });

  it("traduz o tipo do telefone, da placa e da chave Pix", () => {
    assert.deepEqual(descrever({ documento: "telefone", valido: true, tipo: "celular" }).dados, [["Tipo", "celular"]]);
    assert.deepEqual(descrever({ documento: "placa", valido: true, tipo: "mercosul" }).dados, [
      ["Tipo", "placa Mercosul"],
    ]);
    assert.deepEqual(descrever({ documento: "pix", valido: true, tipo: "phone" }).dados, [
      ["Tipo", "chave de celular"],
    ]);
  });

  it("mostra o tipo como veio quando não conhece a tradução", () => {
    assert.deepEqual(descrever({ documento: "pix", valido: true, tipo: "novo" }).dados, [["Tipo", "novo"]]);
  });

  it("mostra o detalhe com o rótulo de cada documento", () => {
    assert.deepEqual(descrever({ documento: "titulo_eleitor", valido: true, detalhe: "PR" }).dados, [
      ["UF de emissão", "PR"],
    ]);
    assert.deepEqual(descrever({ documento: "telefone", valido: true, detalhe: "11" }).dados, [["DDD", "11"]]);
  });

  it("dá nome ao modelo da chave de acesso quando conhece o código", () => {
    assert.deepEqual(descrever({ documento: "chave_acesso", valido: true, detalhe: "55" }).dados, [
      ["Modelo", "NF-e (55)"],
    ]);
    assert.deepEqual(descrever({ documento: "chave_acesso", valido: true, detalhe: "99" }).dados, [["Modelo", "99"]]);
  });

  it("explica o motivo quando é inválido", () => {
    assert.deepEqual(descrever({ documento: "cpf", valido: false, caracteres: 10 }), {
      estado: "invalido",
      titulo: "CPF inválido",
      dados: [],
      motivo: "Tem 10 caracteres, sem contar pontos, traços e espaços. O CPF tem 11.",
    });
  });

  it("mostra a mensagem de erro da API ou da conexão", () => {
    assert.deepEqual(descrever({ erro: "valor muito longo" }), {
      estado: "erro",
      titulo: "Não deu para validar",
      dados: [],
      motivo: "valor muito longo",
    });
  });
});

describe("motivo", () => {
  it("aponta o tamanho errado antes de qualquer outra coisa", () => {
    assert.equal(motivo("cnpj", 13), "Tem 13 caracteres, sem contar pontos, traços e espaços. O CNPJ tem 14.");
    assert.equal(motivo("cep", 1), "Tem 1 caractere, sem contar pontos, traços e espaços. O CEP tem 8.");
  });

  it("avisa quando só havia máscara", () => {
    assert.equal(motivo("cpf", 0), "Não sobrou nenhum caractere depois de tirar pontos, traços e espaços.");
  });

  it("com o tamanho certo, explica a regra do documento", () => {
    assert.equal(motivo("boleto", 48), DOCUMENTOS.boleto.regra);
    assert.equal(motivo("cpf", 11), DOCUMENTOS.cpf.regra);
  });

  it("explica a regra direto quando o tamanho varia", () => {
    assert.equal(motivo("pix", null), DOCUMENTOS.pix.regra);
    assert.equal(motivo("telefone", 9), DOCUMENTOS.telefone.regra);
  });
});

describe("textoRuby", () => {
  it("escreve um texto Ruby entre aspas, sem interpolação", () => {
    assert.equal(textoRuby("123.456.789-09"), '"123.456.789-09"');
    assert.equal(textoRuby('a"b\\c #{x}'), '"a\\"b\\\\c \\#{x}"');
  });
});

describe("trechoRuby", () => {
  it("põe o valor numa variável e mostra as chamadas antes de validar", () => {
    assert.deepEqual(trechoRuby("cpf", " 12345678909 "), [
      'require "br_validators"',
      "",
      'cpf = "12345678909"',
      "",
      "BrValidators::CPF.valid?(cpf)",
      "BrValidators::CPF.format(cpf)",
    ]);
  });

  it("mostra embaixo de cada chamada o que ela devolveu, como o Ruby mostraria", () => {
    const resposta = { valido: true, formatado: "(11) 98765-4321", tipo: "celular", detalhe: "11" };
    assert.deepEqual(trechoRuby("telefone", "11987654321", resposta).slice(4), [
      "BrValidators::Telefone.valid?(telefone)",
      "# => true",
      "BrValidators::Telefone.format(telefone)",
      '# => "(11) 98765-4321"',
      "BrValidators::Telefone.type(telefone)",
      "# => :celular",
      "BrValidators::Telefone.ddd(telefone)",
      '# => "11"',
    ]);
  });

  it("mostra nil nos métodos de um documento inválido", () => {
    const resposta = { valido: false, formatado: null, tipo: null, detalhe: null };
    assert.deepEqual(trechoRuby("pix", "x", resposta).slice(2), [
      'pix = "x"',
      "",
      "BrValidators::Pix.valid?(pix)",
      "# => false",
      "BrValidators::Pix.type(pix)",
      "# => nil",
    ]);
  });
});

describe("DOCUMENTOS", () => {
  it("tem tudo o que a página usa para cada documento", () => {
    for (const [chave, documento] of Object.entries(DOCUMENTOS)) {
      for (const campo of ["mascara", "exemplo", "nome", "rotulo", "dica", "modulo", "regra"]) {
        assert.ok(documento[campo]?.length > 0, `${chave} sem ${campo}`);
      }
      assert.ok(["numeric", "tel", "text"].includes(documento.teclado), `${chave}: teclado`);
      assert.ok(documento.tamanhos === null || documento.tamanhoCerto, `${chave}: tamanhoCerto`);
    }
  });

  it("usa o teclado com letras onde o documento pode ter letras ou símbolos", () => {
    assert.equal(DOCUMENTOS.cnpj.teclado, "text");
    assert.equal(DOCUMENTOS.pix.teclado, "text");
    assert.equal(DOCUMENTOS.placa.teclado, "text");
    assert.equal(DOCUMENTOS.telefone.teclado, "tel");
    assert.equal(DOCUMENTOS.cpf.teclado, "numeric");
  });

  it("tem um botão na página para cada documento, na mesma ordem", () => {
    const html = readFileSync(new URL("../../public/index.html", import.meta.url), "utf8");
    const botoes = [...html.matchAll(/name="documento" value="(\w+)"/g)].map((achado) => achado[1]);
    assert.deepEqual(botoes, Object.keys(DOCUMENTOS));
  });
});

describe("realce", () => {
  it("separa constantes, textos e o resultado de cada chamada", () => {
    assert.deepEqual(realce('cpf = "529.982.247-25"'), [
      ["", "cpf = "],
      ["string", '"529.982.247-25"'],
    ]);
    assert.deepEqual(realce("BrValidators::CPF.valid?(cpf)"), [
      ["constante", "BrValidators::CPF"],
      ["", ".valid?(cpf)"],
    ]);
    assert.deepEqual(realce("# => :mercosul"), [
      ["comentario", "# => "],
      ["literal", ":mercosul"],
    ]);
    assert.deepEqual(realce("# => nil"), [
      ["comentario", "# => "],
      ["literal", "nil"],
    ]);
  });

  it("não perde nenhum caractere, nem com aspas e #{ no valor", () => {
    const resposta = { valido: false, formatado: null, tipo: null, detalhe: null };
    for (const documento of Object.keys(DOCUMENTOS)) {
      for (const linha of trechoRuby(documento, 'a"b#{c}\\d', resposta)) {
        assert.equal(
          realce(linha)
            .map(([, texto]) => texto)
            .join(""),
          linha,
        );
      }
    }
  });

  it("deixa o valor digitado inteiro como texto, sem colorir o que tem dentro", () => {
    assert.deepEqual(realce('pix = "Fulano :x nil \\"oi\\""'), [
      ["", "pix = "],
      ["string", '"Fulano :x nil \\"oi\\""'],
    ]);
  });
});
