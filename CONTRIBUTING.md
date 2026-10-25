# Como contribuir

## Fluxo

1. Toda mudança começa num card do Jira (projeto **BRV**).
2. Crie a branch a partir da `main` com a chave do card: `brv-12-descricao-curta`.
   O card vai sozinho para "Em andamento".
3. Abra o PR com o título começando pela chave: `BRV-12: descrição curta`.
   O card vai para "Em análise".
4. Quando a CI passa e o PR está atualizado com a `main`, ele é mesclado sozinho
   (`.github/workflows/auto-merge.yml`) e o card vai para "Concluído".
   Para segurar um PR, abra como rascunho ou use o rótulo `segurar`.

PR de fork não é mesclado sozinho: precisa de revisão.

## Regras do código

- Código simples, que um dev júnior entenda. Comentários em português explicando o porquê.
- Sem dependências em tempo de execução.
- Todo validador tem `valid?`, `format` e `strip`, e testes com os casos de borda:
  todos os dígitos iguais, com e sem máscara, espaços, tamanho errado, letras onde não pode.
- Cobertura de 100% das linhas (o `test/test_helper.rb` cobra isso).
- Regra de documento sempre conferida na fonte oficial (Receita Federal, Ministério da
  Saúde, Banco Central, FEBRABAN). Coloque o link no comentário do módulo.
- Dados de exemplo sempre fictícios, gerados para os testes.

## Comandos

| Comando | Para quê |
| --- | --- |
| `bundle exec rake test` | Testes com cobertura |
| `bundle exec rubocop` | Estilo |

## Como publicar uma versão

A publicação é automática (`.github/workflows/release.yml`), sem token guardado no
repositório: o RubyGems confia no workflow pelo *trusted publishing*.

1. Num PR normal, suba a versão em `lib/br_validators/version.rb` e troque o
   "[Não lançado]" do `CHANGELOG.md` pela versão e pela data.
2. Depois do merge, crie a tag na `main` com o mesmo número: `git tag v0.2.0 && git push origin v0.2.0`.
3. O workflow confere se a tag bate com a versão, roda os testes e publica.

Use o versionamento semântico: correção → 0.1.1, função nova → 0.2.0, mudança que
quebra quem já usa → 1.0.0.

## Cuidados

- A CI não roda quando o PR só muda arquivos `.md`.
- Merge feito pelo `GITHUB_TOKEN` não dispara outros workflows. Por isso o
  `auto-merge.yml` move o card do Jira ele mesmo.
- Workflows disparados por `workflow_run` usam a versão que está na `main`.
