#!/usr/bin/env zsh

alias kc='source <(kubectl completion zsh)'

kclean() {
  local count
  count="$(kubectl get pods -A --field-selector=status.phase=Failed --no-headers 2>/dev/null | wc -l | tr -d ' ')"

  if [ "$count" = "0" ]; then
    echo "No failed pods to delete"
    return 0
  fi

  _confirm_action "Delete $count failed pod(s) across all namespaces?" || return 1
  kubectl delete pods -A --field-selector=status.phase=Failed
}
