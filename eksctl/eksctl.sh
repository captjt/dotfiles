#!/usr/bin/env zsh

# If eksctl is installed this will provide basic eksctl ZSH completion.
if [ $commands[eksctl] ]; then
  . <(eksctl completion zsh)
fi
