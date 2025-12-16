#!/bin/sh
# Initialize zoxide (smarter cd)
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"

  # Alias cd to z for muscle memory (optional)
  alias cd='z'

  # Use fzf for interactive selection with zi
  export _ZO_FZF_OPTS='--height 40% --reverse'
fi
