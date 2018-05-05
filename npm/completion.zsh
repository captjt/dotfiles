#!/usr/bin/env zsh

# If npm is installed this will provide basic npm ZSH completion.
#
#  See: https://docs.npmjs.com/cli/completion#synopsis
if [ $commands[npm] ]; then
  source <(npm completion)
fi
