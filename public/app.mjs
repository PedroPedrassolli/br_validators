// Liga o formulário da página à API. As regras ficam todas na gem (em Ruby);
// aqui só se monta a pergunta e se mostra a resposta.
import { EXEMPLOS, descrever, urlDaValidacao } from "./resultado.mjs";

const formulario = document.querySelector("#formulario");
const documento = document.querySelector("#documento");
const valor = document.querySelector("#valor");
const exemplo = document.querySelector("#exemplo");
const resultado = document.querySelector("#resultado");

function mostrar({ titulo, detalhes, valido }) {
  // textContent (e não innerHTML) para nunca interpretar o que a pessoa digitou.
  const cabecalho = document.createElement("strong");
  cabecalho.textContent = titulo;

  const lista = document.createElement("ul");
  for (const detalhe of detalhes) {
    const item = document.createElement("li");
    item.textContent = detalhe;
    lista.append(item);
  }

  resultado.replaceChildren(cabecalho, lista);
  resultado.dataset.estado = valido ? "valido" : "invalido";
}

formulario.addEventListener("submit", async (evento) => {
  evento.preventDefault();
  resultado.dataset.estado = "carregando";
  resultado.textContent = "Validando…";

  try {
    const resposta = await fetch(urlDaValidacao(documento.value, valor.value));
    mostrar(descrever(await resposta.json()));
  } catch {
    mostrar({ titulo: "Não deu para falar com o servidor", detalhes: ["Tente de novo em instantes."], valido: false });
  }
});

exemplo.addEventListener("click", () => {
  valor.value = EXEMPLOS[documento.value];
  valor.focus();
});

documento.addEventListener("change", () => {
  valor.value = "";
  resultado.replaceChildren();
  delete resultado.dataset.estado;
});
