#!/usr/bin/env zsh
# Fuzzy cd into directory
fcd() {
  local dir
  dir=$(fd --type d --hidden --exclude .git 2>/dev/null | fzf --preview 'tree -C {} | head -50') &&
    cd "$dir"
}
# Fuzzy open file in editor
fe() {
  local file
  file=$(fzf --preview 'bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || cat {}') &&
    ${EDITOR:-vim} "$file"
}
# Fuzzy git branch checkout
fco() {
  local branch
  branch=$(git branch --all | grep -v HEAD | sed 's/.* //' | sed 's#remotes/origin/##' | sort -u |
    fzf --preview 'git log --oneline --graph --color=always {} | head -50') &&
    git checkout "$branch"
}
# Fuzzy git log browser
flog() {
  git log --oneline --color=always |
    fzf --ansi --preview 'git show --color=always {1}' |
    awk '{print $1}' |
    xargs -I {} git show {}
}
# Fuzzy process kill
fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf --multi | awk '{print $2}')
  if [ -n "$pid" ]; then
    echo "$pid" | xargs kill -${1:-9}
  fi
}
# Fuzzy kubernetes pod selector
if command -v kubectl &>/dev/null; then
  kpod() {
    kubectl get pods --all-namespaces | fzf --header-lines=1 | awk '{print $2 " -n " $1}'
  }

  # Fuzzy kubectl logs
  klogs() {
    local selection=$(kubectl get pods --all-namespaces | fzf --header-lines=1)
    local pod=$(echo $selection | awk '{print $2}')
    local ns=$(echo $selection | awk '{print $1}')
    kubectl logs -f -n "$ns" "$pod"
  }

  # Fuzzy kubectl exec
  kexec() {
    local selection=$(kubectl get pods --all-namespaces | fzf --header-lines=1)
    local pod=$(echo $selection | awk '{print $2}')
    local ns=$(echo $selection | awk '{print $1}')
    kubectl exec -it -n "$ns" "$pod" -- ${1:-/bin/sh}
  }
fi
