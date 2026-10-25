#!/usr/bin/env bash
# Move um card do Jira para outro status, pela API REST do Jira.
# Usado por .github/workflows/jira.yml (no lugar das regras de automação do Jira,
# que no plano Free têm só 150 passos por mês).
#
# Uso: jira-transition.sh CHAVE "Status de destino" categorias-permitidas
#   ex.: jira-transition.sh BRV-14 "Em análise" "new,indeterminate"
# Categorias do status atual (do Jira): new = A fazer, indeterminate = em andamento,
# done = concluído/cancelado. Se o card estiver numa categoria fora da lista,
# nada é feito (ex.: nunca reabrir um card concluído).
#
# Precisa de JIRA_EMAIL e JIRA_API_TOKEN (secrets do GitHub) e JIRA_SITE.
set -euo pipefail

key="$1"
target="$2"
allowed="$3"

if [ -z "${JIRA_EMAIL:-}" ] || [ -z "${JIRA_API_TOKEN:-}" ]; then
  echo "::warning title=Jira::Secrets JIRA_EMAIL e JIRA_API_TOKEN ausentes; o card $key não foi movido."
  exit 0
fi

jira() {
  curl --silent --show-error --fail-with-body \
    --user "$JIRA_EMAIL:$JIRA_API_TOKEN" \
    -H "Accept: application/json" -H "Content-Type: application/json" \
    "$@"
}

issue="https://$JIRA_SITE/rest/api/3/issue/$key"

current=$(jira "$issue?fields=status" | jq -r '.fields.status.name + "|" + .fields.status.statusCategory.key')
current_name="${current%%|*}"
current_category="${current##*|}"

if [ "$current_name" = "$target" ]; then
  echo "$key já está em \"$target\"."
  exit 0
fi

# "Cancelado" fica na categoria "new" no Jira, mas é decisão final: nunca sai dele sozinho.
if [ "$current_name" = "Cancelado" ]; then
  echo "$key está cancelado; não move."
  exit 0
fi

if [[ ",$allowed," != *",$current_category,"* ]]; then
  echo "$key está em \"$current_name\" ($current_category); não move para \"$target\"."
  exit 0
fi

transition=$(jira "$issue/transitions" | jq -r --arg target "$target" \
  '.transitions[] | select(.to.name == $target) | .id' | head -n 1)

if [ -z "$transition" ]; then
  echo "::error title=Jira::Não há transição de \"$current_name\" para \"$target\" no card $key."
  exit 1
fi

jira -X POST "$issue/transitions" --data "{\"transition\":{\"id\":\"$transition\"}}" > /dev/null
echo "::notice title=Jira::$key: \"$current_name\" → \"$target\""
