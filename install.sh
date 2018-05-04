#!/usr/bin/env bash
# This script assumes you already have git configured.

set -e

# Shortcut to this dotfiles path is $DOTFILES
DOTFILES="$HOME/.dotfiles"

# Setup and configure antibody.
# Project page: https://github.com/getantibody/antibody
setup_antibody() {
  command -v antibody >/dev/null && return

  if which brew >/dev/null 2>&1; then
    brew install getantibody/tap/antibody || brew upgrade antibody
  else
    curl -sL https://git.io/antibody | sh -s
  fi
  antibody bundle < "$DOTFILES/antibody/bundles.txt" > ~/.zsh_plugins.sh
  antibody update
}

setup_nvm() {
  command -v nvm >/dev/null && return

  NVM_VERSION="v0.33.11"

  curl -o- https://raw.githubusercontent.com/creationix/nvm/"$NVM_VERSION"/install.sh | bash
}

setup_go() {
  # If Go already exists just return
  [ -d ~/go ] && return

  cd ~
  git clone https://go.googlesource.com/go
  cd go/src
  echo ' Building Go'
  ./all.bash
}

setup_docker() {
  mkdir -p "$HOME/.docker/completions"

  if which docker-compose >/dev/null 2>&1; then
    curl -sL https://raw.githubusercontent.com/docker/compose/master/contrib/completion/zsh/_docker-compose \
      -o "$HOME/.docker/completions/_docker-compose"
  fi

  if which docker-machine >/dev/null 2>&1; then
    curl -sL https://raw.githubusercontent.com/docker/machine/master/contrib/completion/zsh/_docker-machine \
      -o "$HOME/.docker/completions/_docker-machine"
  fi

  if which docker >/dev/null 2>&1; then
    curl -sL https://raw.githubusercontent.com/docker/cli/master/contrib/completion/zsh/_docker \
      -o "$HOME/.docker/completions/_docker"
  fi
}

setup_fonts() {
  URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/FiraCode.zip"

  install() {
    curl -L -s -o /tmp/fura.zip "$URL"
    unzip /tmp/fura.zip -d /tmp
    cp /tmp/FiraCode/*.ttf "$2"
  }

  if [ "$(uname -s)" = "Darwin" ]; then
    if which brew >/dev/null 2>&1; then
      brew cask install font-firacode-nerd-font
      brew cask install font-firacode-nerd-font-mono
    else
      install ~/Library/Fonts
    fi
  else
    mkdir -p ~/.fonts
    install ~/.fonts
  fi
}

# Standard dotbot pre-configuration:
CONFIG="install.conf.yaml"
DOTBOT_DIR="dotbot"

DOTBOT_BIN="bin/dotbot"
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Update submodules and bootstrap with dotbot. If running on OSX install all
#  brews from Brewfile.
cd "${BASEDIR}"
git submodule update --init --recursive "${DOTBOT_DIR}"

# Check the OS - install with dotbot-brew if on Darwin based machine.
if [ "$(uname -s)" = "Darwin" ]; then
  "${BASEDIR}/${DOTBOT_DIR}/${DOTBOT_BIN}" -d "${BASEDIR}" \
    --plugin-dir dotbot-brew \
    -c "${CONFIG}" "${@}"
elif [ "$(uname -s)" = "Linux" ]; then
  "${BASEDIR}/${DOTBOT_DIR}/${DOTBOT_BIN}" -d "${BASEDIR}" \
    -c "${CONFIG}" "${@}"
else
  echo ' This should never hit here'
  echo '  -> ¯\_(ツ)_/¯ '
  exit 1
fi

# Check your current shell. If your active shell is ZSH setup antibody.
case $SHELL in
*/zsh)
  setup_antibody
  ;;
*)
  echo ' Activate ZSH!'
  echo '  -> chsh -s =zsh'
  exit 1
esac

setup_docker
setup_fonts
setup_go
setup_nvm
