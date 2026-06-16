#!/usr/bin/env zsh

# If Azure CLI is installed - generally this is on an OSX machine for the time
# being.
if [ $commands[az] ]; then
  autoload bashcompinit && bashcompinit
  if [ -r /opt/homebrew/etc/bash_completion.d/az ]; then
    source /opt/homebrew/etc/bash_completion.d/az
  elif [ -r /usr/local/etc/bash_completion.d/az ]; then
    source /usr/local/etc/bash_completion.d/az
  fi
fi
