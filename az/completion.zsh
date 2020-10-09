#!/usr/bin/env zsh

# If Azure CLI is installed - generally this is on an OSX machine for the time
# being.
# if [ $commands[az] ]; then
autoload bashcompinit && bashcompinit
source /usr/local/etc/bash_completion.d/az
# fi
