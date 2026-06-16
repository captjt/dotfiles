#!/usr/bin/env zsh

_gh_required() {
  if ! command -v gh >/dev/null 2>&1; then
    echo "gh is not installed"
    return 1
  fi
}

ghpr() {
  _gh_required || return

  if [ -n "${1:-}" ]; then
    gh pr view "$1" --comments
  else
    gh pr view --comments
  fi
}

ghchecks() {
  _gh_required || return

  if [ -n "${1:-}" ]; then
    gh pr checks "$1"
  else
    gh pr checks
  fi
}

ghrun() {
  _gh_required || return

  if [ -n "${1:-}" ]; then
    gh run view "$1" --log
  else
    gh run list --limit 10
  fi
}

ghreview() {
  _gh_required || return

  local pr="${1:-}"
  if [ -n "$pr" ]; then
    gh pr view "$pr" --comments
    gh pr diff "$pr"
  else
    gh pr view --comments
    gh pr diff
  fi
}
