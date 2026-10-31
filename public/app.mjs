// Liga a página à API. As regras ficam todas na gem (em Ruby); aqui só se monta
// a pergunta e se mostra a resposta.
import { DOCUMENTOS, descrever, trechoRuby, urlDaValidacao } from "./resultado.mjs";

const formulario = document.querySelector("#formulario");
const valor = document.querySelector("#valor");
const rotulo = document.querySelector("#rotulo");
const dica = document.querySelector("#dica");
const validar = document.querySelector("#validar");
const exemplo = document.querySelector("#exemplo");
const resultado = document.querySelector("#resultado");
const trecho = document.querySelector("#trecho");
const rails = document.querySelector("#rails");

// A função Ruby responde em menos de 1 segundo; depois disso, algo deu errado.
const ESPERA_MAXIMA_MS = 10_000;

// Desenhos dos ícones do carimbo (traços de um quadro de 24 x 24).
const ICONES = {
  valido: "M5 12.5l4.5 4.5L19 7.5",
  invalido: "M6.5 6.5l11 11M17.5 6.5l-11 11",
  erro: "M12 6.5v7M12 17.5v.01",
};

// Número do pedido mais recente. Se a pessoa trocar de documento ou mexer no
// campo enquanto espera, a resposta antiga chega depois e é ignorada.
let pedidoAtual = 0;

function documentoAtual() {
  return formulario.elements.documento.value;
}

function criar(tag, texto, classe) {
  const elemento = document.createElement(tag);
  if (texto != null) elemento.textContent = texto;
  if (classe) elemento.className = classe;
  return elemento;
}

function icone(estado) {
  const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
  svg.setAttribute("viewBox", "0 0 24 24");
  svg.setAttribute("fill", "none");
  svg.setAttribute("stroke", "currentColor");
  svg.setAttribute("stroke-width", "2.75");
  svg.setAttribute("stroke-linecap", "round");
  svg.setAttribute("stroke-linejoin", "round");
  svg.setAttribute("aria-hidden", "true");
  const caminho = document.createElementNS("http://www.w3.org/2000/svg", "path");
  caminho.setAttribute("d", ICONES[estado]);
  svg.append(caminho);
  return svg;
}

function botaoCopiar(texto) {
  const botao = criar("button", "Copiar", "copiar");
  botao.type = "button";
  botao.dataset.texto = texto;
  return botao;
}

// Mostra o resultado. Sempre com textContent (e não innerHTML), para nunca
// interpretar o que a pessoa digitou.
function mostrar({ estado, titulo, dados, motivo }) {
  const carimbo = criar("p", null, "carimbo");
  carimbo.dataset.estado = estado;
  carimbo.append(icone(estado), criar("strong", titulo));
  const partes = [carimbo];

  if (motivo) partes.push(criar("p", motivo, "motivo"));

  if (dados.length > 0) {
    const lista = criar("dl", null, "dados");
    for (const [nome, texto] of dados) {
      const valorDado = criar("dd");
      valorDado.append(criar("code", texto));
      // Só o documento formatado vale a pena copiar.
      if (nome === "Formatado") valorDado.append(botaoCopiar(texto));
      lista.append(criar("dt", nome), valorDado);
    }
    partes.push(lista);
  }

  resultado.replaceChildren(...partes);
}

// Trecho de código Ruby que faz o mesmo que a página. Sem resposta, mostra só as
// chamadas; depois de validar, mostra também o que cada uma devolveu.
function atualizarTrecho(resposta = null) {
  const documento = documentoAtual();
  const texto = valor.value.trim() || DOCUMENTOS[documento].exemplo;
  // As linhas de resultado ("# => ...") ficam na cor dos comentários.
  const partes = trechoRuby(documento, texto, resposta).flatMap((linha) => [
    linha.startsWith("#") ? criar("span", linha, "comentario") : linha,
    "\n",
  ]);
  trecho.replaceChildren(...partes);
  rails.textContent = `validates :${documento}, ${documento}: true`;
}

function limparResultado() {
  pedidoAtual++;
  validar.disabled = false;
  resultado.replaceChildren();
}

// Rótulo, dica e teclado do celular de acordo com o documento escolhido.
function ajustarCampo() {
  const campo = DOCUMENTOS[documentoAtual()];
  rotulo.textContent = campo.rotulo;
  dica.textContent = campo.dica;
  valor.inputMode = campo.teclado;
  atualizarTrecho();
}

formulario.addEventListener("submit", async (evento) => {
  evento.preventDefault();
  const pedido = ++pedidoAtual;

  // Botão desligado enquanto espera: evita mandar o mesmo pedido duas vezes.
  validar.disabled = true;
  resultado.replaceChildren(criar("p", "Validando…", "carregando"));

  let resposta;
  try {
    const retorno = await fetch(urlDaValidacao(documentoAtual(), valor.value), {
      signal: AbortSignal.timeout(ESPERA_MAXIMA_MS),
    });
    resposta = await retorno.json();
  } catch {
    resposta = { erro: "O servidor não respondeu. Confira a conexão e tente de novo." };
  }

  if (pedido !== pedidoAtual) return;
  validar.disabled = false;
  mostrar(descrever(resposta));
  atualizarTrecho(resposta.erro ? null : resposta);
});

// O exemplo já valida sozinho: um clique e a pessoa vê como a página funciona.
exemplo.addEventListener("click", () => {
  valor.value = DOCUMENTOS[documentoAtual()].exemplo;
  formulario.requestSubmit();
});

// Trocou de documento: o formato muda, então o campo e o resultado começam do zero.
// O endereço guarda a escolha (?documento=placa), para dar para mandar o link.
formulario.addEventListener("change", (evento) => {
  if (evento.target.name !== "documento") return;
  limparResultado();
  valor.value = "";
  ajustarCampo();
  history.replaceState(null, "", `?documento=${documentoAtual()}`);
});

// Mexeu no número: o resultado anterior já não vale, e o trecho de código acompanha.
valor.addEventListener("input", () => {
  if (resultado.hasChildNodes()) limparResultado();
  atualizarTrecho();
});

// Qualquer botão "Copiar" da página: copia o texto dele ou o do elemento indicado.
document.addEventListener("click", async (evento) => {
  const botao = evento.target.closest("button.copiar");
  if (!botao) return;
  const texto = botao.dataset.texto ?? document.getElementById(botao.dataset.copiar).textContent;
  try {
    await navigator.clipboard.writeText(texto);
    botao.textContent = "Copiado";
  } catch {
    botao.textContent = "Não deu para copiar";
  }
  setTimeout(() => (botao.textContent = "Copiar"), 1500);
});

// Abre no documento do link (?documento=placa), se houver um.
const doLink = new URLSearchParams(location.search).get("documento");
if (Object.hasOwn(DOCUMENTOS, doLink ?? "")) formulario.elements.documento.value = doLink;
ajustarCampo();
