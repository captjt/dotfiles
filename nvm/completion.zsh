#!/usr/bin/env zsh

export NVM_DIR="$HOME/.nvm"
# If nvm is installed - generally this is on an OSX machine for the time being.
if [ -s "$NVM_DIR/bash_completion" ]; then
  source "$NVM_DIR/bash_completion"
fi
