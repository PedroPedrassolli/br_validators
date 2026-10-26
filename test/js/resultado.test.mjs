// Testes das funções da página: node --test "test/js/*.test.mjs"
import assert from "node:assert/strict";
import { describe, it } from "node:test";

import { CAMPOS, EXEMPLOS, descrever, urlDaValidacao } from "../../public/resultado.mjs";

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
    assert.deepEqual(texto, { titulo: "Válido", detalhes: ["Formatado: 123.456.789-09"], valido: true });
  });

  it("traduz o tipo do telefone e da placa", () => {
    assert.deepEqual(descrever({ valido: true, formatado: "(11) 98765-4321", tipo: "celular" }).detalhes, [
      "Formatado: (11) 98765-4321",
      "Tipo: celular",
    ]);
    assert.deepEqual(descrever({ valido: true, formatado: "BRA2E19", tipo: "mercosul" }).detalhes, [
      "Formatado: BRA2E19",
      "Tipo: placa Mercosul",
    ]);
  });

  it("traduz o tipo da chave Pix", () => {
    const texto = descrever({ documento: "pix", valido: true, formatado: null, tipo: "phone" });
    assert.deepEqual(texto.detalhes, ["Tipo: chave de celular"]);
  });

  it("mostra o tipo como veio quando não conhece a tradução", () => {
    const texto = descrever({ documento: "pix", valido: true, formatado: null, tipo: "novo" });
    assert.deepEqual(texto.detalhes, ["Tipo: novo"]);
  });

  it("marca como inválido e aponta para a dica do campo", () => {
    assert.deepEqual(descrever({ documento: "cpf", valido: false, formatado: null, tipo: null }), {
      titulo: "Inválido",
      detalhes: ["Confira o número e o formato indicado embaixo do campo."],
      valido: false,
    });
  });

  it("mostra a mensagem de erro da API", () => {
    const texto = descrever({ erro: "valor muito longo" });
    assert.deepEqual(texto, { titulo: "Não deu para validar", detalhes: ["valor muito longo"], valido: false });
  });
});

describe("EXEMPLOS", () => {
  it("tem um exemplo para cada documento do formulário", () => {
    assert.deepEqual(Object.keys(EXEMPLOS), [
      "cpf",
      "cnpj",
      "cns",
      "pix",
      "boleto",
      "titulo_eleitor",
      "cep",
      "telefone",
      "placa",
      "renavam",
      "chave_acesso",
      "processo_cnj",
    ]);
  });
});

describe("CAMPOS", () => {
  it("tem dica e teclado para cada documento do formulário", () => {
    assert.deepEqual(Object.keys(CAMPOS), Object.keys(EXEMPLOS));
    for (const { dica, teclado } of Object.values(CAMPOS)) {
      assert.ok(dica.length > 0);
      assert.ok(["numeric", "tel", "text"].includes(teclado));
    }
  });

  it("usa o teclado com letras onde o documento pode ter letras ou símbolos", () => {
    assert.equal(CAMPOS.cnpj.teclado, "text");
    assert.equal(CAMPOS.pix.teclado, "text");
    assert.equal(CAMPOS.placa.teclado, "text");
    assert.equal(CAMPOS.telefone.teclado, "tel");
    assert.equal(CAMPOS.cpf.teclado, "numeric");
  });
});
