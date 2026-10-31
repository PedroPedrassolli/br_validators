// Aplica o tema salvo antes de a página aparecer, para não abrir no tema errado e
// trocar na frente da pessoa. Escuro é o padrão, como no portfólio.
// Fica num arquivo (e não dentro do HTML) porque a Content-Security-Policy só deixa
// rodar scripts do próprio site. A troca pelo botão fica no app.mjs.
(function () {
  var tema = null;
  try {
    tema = localStorage.getItem("tema");
  } catch (erro) {
    // Navegação privada pode bloquear o localStorage: segue no escuro.
  }
  if (tema === "claro") {
    document.documentElement.dataset.tema = "claro";
    // Cor da barra do navegador no celular, igual ao fundo da página.
    document.querySelector('meta[name="theme-color"]').content = "#fafafc";
  }
})();
