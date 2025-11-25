#!/usr/bin/env zsh
export NVM_DIR="$HOME/.nvm"
nvm() {
  unfunction nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
  nvm "$@"
}
node() { nvm; node "$@" }
npm() { nvm; npm "$@" }
npx() { nvm; npx "$@" }
