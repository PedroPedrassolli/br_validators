# Changelog

As mudanças de cada versão ficam aqui. O projeto segue o
[versionamento semântico](https://semver.org/lang/pt-BR/).

## [Não lançado]

- Estrutura inicial da gem, testes com Minitest e CI no GitHub Actions.
- `BrValidators::CPF` com `valid?`, `format` e `strip`.
- `BrValidators::CNPJ` para o formato numérico e o alfanumérico da Receita Federal.
- `BrValidators::CNS` com as rotinas de validação do Ministério da Saúde.
- `BrValidators::Pix` com `valid?` e `type`, seguindo a especificação do DICT.
- `BrValidators::Boleto` para a linha digitável de cobrança (47 dígitos) e de arrecadação (48 dígitos).
- Validadores para ActiveModel (`validates :cpf, cpf: true` e afins) com mensagens em pt-BR e en.
