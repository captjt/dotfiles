#!/usr/bin/env zsh

# Add each topic folder to fpath so that they can add functions and completion
#  scripts.
for topic_folder in $DOTFILES/*; do
  if [ -d "$topic_folder" ]; then
    fpath=($topic_folder $fpath)
  fi
done

# Add .local zsh completions if you have any defined.
fpath=(~/.local/zsh_completions $fpath)

if [ "$(uname -s)" = "Darwin" ]; then
  fpath=(/usr/local/share/zsh/site-functions $fpath)
fi
