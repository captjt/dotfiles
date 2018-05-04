#!/usr/bin/env bash
# This script assumes you already have git configured.
#
# Process is to install ZIM (ZSH Framework) if needed. Then install Go, nvm and
#  Powerlevel9k (ZSH Theme). Then bootstrap dotbot with the requirements
#  necessary for the local OS.

set -e

setup_zim() {
  [ -d ~/.zim ] && return

  echo ' Installing ZIM'

  git clone --recursive https://github.com/zimfw/zimfw.git ${ZDOTDIR:-${HOME}}/.zim

  echo '
  After this completes copy and paste this into your Zsh terminal to finish the
    ZIM setup.


  setopt EXTENDED_GLOB
  for template_file in ${ZDOTDIR:-${HOME}}/.zim/templates/*; do
    user_file="${ZDOTDIR:-${HOME}}/.${template_file:t}"
    touch ${user_file}
    ( print -rn "$(<${template_file})$(<${user_file})" >! ${user_file} ) 2>/dev/null
  done
'
}

# Check your current shell. If your active shell is ZSH install ZIM.
case $SHELL in
*/zsh)
  setup_zim
  ;;
*)
  echo ' Activate ZSH!'
  echo '  -> chsh -s =zsh'
esac

go_version="$(go version 2>/dev/null)"
setup_go() {
  # If Go already exists just return
  [ -d ~/go ] && return

  cd ~
  git clone https://go.googlesource.com/go
  cd go/src
  echo ' Building Go'
  ./all.bash
}

setup_powerlevel9k() {
  # If powerlevel9k already exists just return.
  [ -d ~/.zim/modules/prompt/external-themes/powerlevel9k ] && return

  git clone https://github.com/bhilburn/powerlevel9k.git \
    ~/.zim/modules/prompt/external-themes/powerlevel9k

  ln -s ~/.zim/modules/prompt/external-themes/powerlevel9k/powerlevel9k.zsh-theme \
    ~/.zim/modules/prompt/functions/prompt_powerlevel9k_setup
}

NVM_VERSION="v0.33.11"
setup_nvm() {
  command -v nvm >/dev/null && return

  curl -o- https://raw.githubusercontent.com/creationix/nvm/"$NVM_VERSION"/install.sh | bash
}

setup_go
echo ' Go installed: '
echo "  -> $go_version"

setup_powerlevel9k
setup_nvm

# Standard dotbot pre-configuration:
CONFIG="install.conf.yaml"
DOTBOT_DIR="dotbot"

DOTBOT_BIN="bin/dotbot"
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

uname="$(uname)"
unameu=$(tr '[:lower:]' '[:upper:]' <<<"$uname")
if [[ ${unameu} == *DARWIN* ]]; then
  OS="darwin"
elif [[ ${unameu} == *LINUX* ]]; then
  OS="linux"
else
  echo " Unsupported or unknown OS: $uname"
  echo '  -> OS must be either linux or darwin'
  exit 1
fi

# Update submodules and bootstrap with dotbot. If running on OSX install all
#  brews from Brewfile.
cd "${BASEDIR}"
git submodule update --init --recursive "${DOTBOT_DIR}"

if [[ $OS == "darwin" ]]; then
  "${BASEDIR}/${DOTBOT_DIR}/${DOTBOT_BIN}" -d "${BASEDIR}" \
    --plugin-dir dotbot-brewfile \
    -c "${CONFIG}" "${@}"
elif [[ $OS == "linux" ]]; then
  "${BASEDIR}/${DOTBOT_DIR}/${DOTBOT_BIN}" -d "${BASEDIR}" \
    -c "${CONFIG}" "${@}"
else
  echo ' This should never hit here'
  echo '  -> ¯\_(ツ)_/¯ '
  exit 1
fi
