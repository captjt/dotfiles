set shell := ["zsh", "-cu"]

shell_files := "config/zshrc zsh/*.zsh fzf/*.zsh kubernetes/*.zsh gcloud/*.zsh docker/*.zsh nvm/*.zsh pyenv/*.zsh rust/*.zsh go/*.zsh homebrew/*.zsh az/*.zsh npm/*.zsh just/*.zsh zoxide/*.zsh direnv/*.zsh mise/*.zsh github/*.zsh"
bash_files := "install.sh bin/agent-handoff bin/gauth bin/gcr-reports bin/k8s-new-user bin/k8s-resource-requests bin/install_kubectl bin/install_terraform bin/install_terragrunt bin/install_gcloud bin/install_go_osx"

default:
  just --list

check: shell-syntax shellcheck opencode-typecheck secrets

agent-skills:
  ./install.sh --agent-skills

shell-syntax:
  zsh -n {{shell_files}}
  bash -n {{bash_files}}

shellcheck:
  shellcheck {{bash_files}}

opencode-typecheck:
  cd opencode && bun install --frozen-lockfile && bun run typecheck

secrets:
  if command -v gitleaks >/dev/null 2>&1; then gitleaks detect --source . --redact; else echo "gitleaks is not installed"; fi

brew-check:
  brew bundle check --file Brewfile

doctor:
  echo "Dotfiles: $PWD"
  git status --short
  command -v codex >/dev/null 2>&1 && codex --version 2>/dev/null || true
  command -v opencode >/dev/null 2>&1 && opencode --version 2>/dev/null || true
  command -v gh >/dev/null 2>&1 && gh --version | head -1 || true
  command -v direnv >/dev/null 2>&1 && direnv version || true
  command -v mise >/dev/null 2>&1 && mise --version || true
