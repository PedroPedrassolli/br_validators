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
  Saúde, Banco Central, FEBRABAN, Anatel, CONTRAN/Denatran, CNJ, Portal da NF-e). Coloque o
  link no comentário do módulo. Sem fonte oficial pública (como PIS/NIS e CNH hoje), o
  documento fica de fora; o título de eleitor é a exceção documentada no módulo.
- Dados de exemplo sempre fictícios, gerados para os testes.
- Os testes nunca chamam a internet: as consultas online (`consulta.rb`) usam um cliente
  falso, e o cliente HTTP é testado contra um servidor local.

## Comandos

| Comando | Para quê |
| --- | --- |
| `bundle exec rake test` | Testes com cobertura |
| `bundle exec rubocop` | Estilo |
| `node --test "test/js/*.test.mjs"` | Testes da página (`public/`) |
| `npx prettier@3.8.1 --check public test/js vercel.json` | Formatação da página (mesma versão da CI) |

## Como publicar uma versão

A publicação é automática (`.github/workflows/release.yml`), sem token guardado no
repositório: o RubyGems confia no workflow pelo *trusted publishing*.

1. Num PR normal, suba a versão em `lib/br_validators/version.rb` e troque o
   "[Não lançado]" do `CHANGELOG.md` pela versão e pela data.
2. Depois do merge, na aba **Actions → Release → Run workflow**, rode na `main`. O workflow
   roda os testes, cria a tag `vX.Y.Z` da versão e publica.
   (Também funciona criando a tag você mesmo: `git tag v0.2.0 && git push origin v0.2.0`.)

Use o versionamento semântico: correção → 0.1.1, função nova → 0.2.0, mudança que
quebra quem já usa → 1.0.0.

## Cuidados

- A CI roda em todo PR, inclusive nos que só mudam arquivos `.md`.
- Merge feito pelo `GITHUB_TOKEN` não dispara outros workflows. Por isso o
  `auto-merge.yml` move o card do Jira ele mesmo.
- Workflows disparados por `workflow_run` usam a versão que está na `main`.
- As Actions dos workflows ficam fixadas pelo commit (SHA), com a versão num comentário.
  Não troque por `@v7`: uma tag pode ser movida para outro código. O Dependabot atualiza.
- O script `.github/scripts/jira-transition.sh` nunca deixa um job vermelho: se o card
  não existe ou o Jira não responde, ele só avisa.
- Se você mudar o `auto-merge.yml`, abra o PR como rascunho: até o merge, quem decide é a
  versão antiga, que está na `main`.
- **Vercel no plano gratuito**: cada deploy guarda uma cópia da função Ruby, e o espaço
  (Function Storage) é limitado. Por isso:
  - não há prévia por PR (`git.deploymentEnabled` no `vercel.json`): só a `main` publica;
  - a produção só é publicada quando a página, a API ou a gem mudam
    (`scripts/vercel-ignorar-build.sh`). PR só de README ou de workflow não gera deploy.
  - A CI cobre o que a prévia conferia: testa a função `api/validar.rb` e a página.
- A função `api/validar.rb` responde com cache de 1 dia na Vercel (a resposta só depende
  da URL). Isso economiza execuções no plano gratuito.
