#!/usr/bin/env zsh
if command -v fzf &>/dev/null; then
  # Initialize fzf keybindings and completion
  source <(fzf --zsh)
  # Use ripgrep for file searching (respects .gitignore)
  export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

  # Preview files with syntax highlighting (uses bat if available)
  if command -v bat &>/dev/null; then
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
  fi
  # Better history search
  export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:wrap"
  # Use fd for directory searching if available
  if command -v fd &>/dev/null; then
    export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
    export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -50'"
  fi
  # Appearance
  export FZF_DEFAULT_OPTS='
    --height 40%
    --reverse
    --border
    --info=inline
    --bind "ctrl-y:execute-silent(echo -n {+} | pbcopy)"
  '
fi
