#!/bin/sh

# If npm is installed this will provide basic npm ZSH completion.
#
#  See: https://docs.npmjs.com/cli/completion#synopsis
if [ $commands[cargo] ]; then
  source "$HOME"/.cargo/env
fi
