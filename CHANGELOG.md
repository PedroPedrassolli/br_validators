# Changelog

As mudanças de cada versão ficam aqui. O projeto segue o
[versionamento semântico](https://semver.org/lang/pt-BR/).

## [0.2.0] - 2026-10-26

### Novo

- `BrValidators::Consulta` (opcional, `require "br_validators/consulta"`): consultas online
  pela BrasilAPI de CEP (endereço), CNPJ (dados da Receita), banco (código de compensação)
  e DDD (UF e cidades). Só usa a biblioteca padrão do Ruby; valida o dado antes de
  consultar, devolve `nil` quando não acha e levanta `BrValidators::Consulta::Erro` quando
  a BrasilAPI não responde.

- `BrValidators::CEP`: formato do CEP.
- `BrValidators::Telefone`: fixo e celular, com os 67 DDDs da Anatel; `type`, `format` e `ddd`.
- `BrValidators::Placa`: placa antiga e Mercosul; `type`, `mercosul` e `antiga` para converter.
- `BrValidators::RENAVAM`: 11 dígitos com dígito verificador.
- `BrValidators::TituloEleitor`: 12 dígitos, dígitos verificadores e `uf`.
- `BrValidators::ProcessoCNJ`: numeração única do CNJ (módulo 97) e `segmento`.
- `BrValidators::ChaveAcesso`: chave de NF-e, NFC-e, CT-e e MDF-e, inclusive com CNPJ
  alfanumérico, e `modelo`.
- Validadores do ActiveModel para todos eles (`cep: true`, `telefone: true`, `placa: true`,
  `renavam: true`, `titulo_eleitor: true`, `processo_cnj: true`, `chave_acesso: true`),
  com mensagens em pt-BR e en.

## [0.1.1] - 2026-10-25

### Corrigido

- CNPJ: letras fora do ASCII, como `ı` (i sem ponto) e `ß`, não viram mais letras
  válidas ao passar para maiúsculas. Antes, `"12abcı3450de60"` passava como válido.
- Texto com bytes inválidos (UTF-8 quebrado) devolve `false` em vez de levantar
  `ArgumentError`.
- Espaços Unicode, como o espaço não separável que vem ao copiar de PDFs e sites,
  contam como máscara em CPF, CNPJ, CNS e boleto, e são ignorados nas pontas da chave Pix.

### Outros

- Página para testar os validadores no navegador (https://br-validators.vercel.app).
- Publicação também pelo botão "Run workflow", recusando versão já publicada.

## [0.1.0] - 2026-10-25

- `BrValidators::CPF` com `valid?`, `format` e `strip`.
- `BrValidators::CNPJ` para o formato numérico e o alfanumérico da Receita Federal.
- `BrValidators::CNS` com as rotinas de validação do Ministério da Saúde.
- `BrValidators::Pix` com `valid?` e `type`, seguindo a especificação do DICT.
- `BrValidators::Boleto` para a linha digitável de cobrança (47 dígitos) e de arrecadação (48 dígitos).
- Validadores para ActiveModel (`validates :cpf, cpf: true` e afins) com mensagens em pt-BR e en.
- Publicação automática no RubyGems ao criar uma tag.
