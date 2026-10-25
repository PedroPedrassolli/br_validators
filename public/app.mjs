// Liga o formulário da página à API. As regras ficam todas na gem (em Ruby);
// aqui só se monta a pergunta e se mostra a resposta.
import { CAMPOS, EXEMPLOS, descrever, urlDaValidacao } from "./resultado.mjs";

const formulario = document.querySelector("#formulario");
const documento = document.querySelector("#documento");
const valor = document.querySelector("#valor");
const dica = document.querySelector("#dica");
const validar = document.querySelector("#validar");
const exemplo = document.querySelector("#exemplo");
const resultado = document.querySelector("#resultado");

// A função Ruby responde em menos de 1 segundo; depois disso, algo deu errado.
const ESPERA_MAXIMA_MS = 10_000;

// Número do pedido mais recente. Se a pessoa trocar de documento enquanto espera,
// a resposta antiga chega depois e é ignorada.
let pedidoAtual = 0;

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

// Dica embaixo do campo e teclado do celular de acordo com o documento escolhido.
function ajustarCampo() {
  const campo = CAMPOS[documento.value];
  dica.textContent = campo.dica;
  valor.inputMode = campo.teclado;
}

formulario.addEventListener("submit", async (evento) => {
  evento.preventDefault();
  const pedido = ++pedidoAtual;

  // Botão desligado enquanto espera: evita mandar o mesmo pedido duas vezes.
  validar.disabled = true;
  resultado.dataset.estado = "carregando";
  resultado.textContent = "Validando…";

  let descricao;
  try {
    const resposta = await fetch(urlDaValidacao(documento.value, valor.value), {
      signal: AbortSignal.timeout(ESPERA_MAXIMA_MS),
    });
    descricao = descrever(await resposta.json());
  } catch {
    descricao = {
      titulo: "Não deu para falar com o servidor",
      detalhes: ["Tente de novo em instantes."],
      valido: false,
    };
  }

  if (pedido !== pedidoAtual) return;
  validar.disabled = false;
  mostrar(descricao);
});

exemplo.addEventListener("click", () => {
  valor.value = EXEMPLOS[documento.value];
  valor.focus();
});

documento.addEventListener("change", () => {
  pedidoAtual++;
  validar.disabled = false;
  valor.value = "";
  resultado.replaceChildren();
  delete resultado.dataset.estado;
  ajustarCampo();
});

// O navegador pode lembrar o documento escolhido ao voltar para a página.
ajustarCampo();
