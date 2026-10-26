#!/usr/bin/env bash
# A Vercel roda este script antes de cada build ("ignoreCommand" no vercel.json).
#   saída 0 = pula o build (nenhum deploy novo);
#   saída 1 = faz o build e publica.
#
# Por quê: no plano gratuito, cada deploy guarda uma cópia da função Ruby e o
# espaço para isso (Function Storage) é limitado. Só vale publicar quando muda
# algo que a página ou a API usam.
#
# As prévias (branches que não são a main) já vêm desligadas pelo
# git.deploymentEnabled do vercel.json; a checagem do VERCEL_ENV é uma garantia.

if [ "$VERCEL_ENV" != "production" ]; then
  echo "Não é produção: sem deploy (a CI já testa a página e a API)."
  exit 0
fi

# HEAD^ é o commit anterior da main. Um merge que só mudou README, testes ou
# workflows não mexe em nada do que vai para o ar.
# O ":!" exclui arquivos da comparação: a API não carrega as consultas online
# (consulta.rb) nem usa o número da versão (version.rb).
if git diff --quiet HEAD^ HEAD -- api public lib vercel.json Gemfile \
  ':!lib/br_validators/consulta.rb' ':!lib/br_validators/version.rb'; then
  echo "Nada da página, da API ou da gem mudou: sem deploy."
  exit 0
fi

echo "A página, a API ou a gem mudou: publicando."
exit 1
