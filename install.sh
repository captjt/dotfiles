#!/usr/bin/env bash
# This script assumes you already have git configured.

set -e

# Shortcut to this dotfiles path is $DOTFILES
DOTFILES="$HOME/.dotfiles"

# Setup and configure antibody.
# Project page: https://github.com/getantibody/antibody
setup_antibody() {
	command -v antibody >/dev/null && return

	if command -v brew >/dev/null 2>&1; then
		brew install getantibody/tap/antibody || brew upgrade antibody
	else
		curl -sL https://git.io/antibody | sh -s
	fi

	antibody bundle < "$DOTFILES/antibody/bundles.txt" > ~/.zsh_plugins.sh
	antibody update
}

setup_nvm() {
	command -v nvm >/dev/null && return

	NVM_VERSION="v0.39.1"

	curl -o- https://raw.githubusercontent.com/creationix/nvm/"$NVM_VERSION"/install.sh | bash
}

setup_go() {
	command -v go >/dev/null && return

	if [ "$(uname -s)" = "Linux" ]; then
		sudo snap install --classic go
	fi
}

setup_docker() {
	mkdir -p "$HOME/.docker/completions"

	if command -v docker-compose >/dev/null 2>&1; then
		curl -sL https://raw.githubusercontent.com/docker/compose/master/contrib/completion/zsh/_docker-compose \
		-o "$HOME/.docker/completions/_docker-compose"
	fi

	if command -v docker-machine >/dev/null 2>&1; then
		curl -sL https://raw.githubusercontent.com/docker/machine/master/contrib/completion/zsh/_docker-machine \
		-o "$HOME/.docker/completions/_docker-machine"
	fi

	if command -v docker >/dev/null 2>&1; then
		curl -sL https://raw.githubusercontent.com/docker/cli/master/contrib/completion/zsh/_docker \
		-o "$HOME/.docker/completions/_docker"
	fi
}

setup_vscode() {
  	command -v code >/dev/null && return

	if [ "$(uname -s)" = "Darwin" ]; then
    	brew cask install visual-studio-code
	else
		sudo snap install vscode --classic
  	fi
}

setup_starship() {
	command -v starship >/dev/null && return

	if [ "$(uname -s)" = "Darwin" ]; then
    	brew install starship
	else
		curl -fsSL https://starship.rs/install.sh | bash
  	fi
}

# Standard dotbot pre-configuration:
BASE_CONFIG_PREFIX="base"
MAC_CONFIG_PREFIX="mac"
CONFIG_SUFFIX=".conf.yaml"
DOTBOT_DIR="dotbot"
DOTBOT_BREW_DIR="dotbot-brew"

DOTBOT_BIN="bin/dotbot"
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Update submodules and bootstrap with dotbot. If running on OSX install all
#  brews from Brewfile.
cd "${BASEDIR}"
git submodule update --init --recursive "${DOTBOT_DIR}"

# Check the OS - install Brews with dotbot-brew if on Darwin based machine.
if [ "$(uname -s)" = "Darwin" ]; then
	git submodule update --init --recursive "${DOTBOT_BREW_DIR}"

	"${BASEDIR}/${DOTBOT_DIR}/${DOTBOT_BIN}" -d "${BASEDIR}" \
		--plugin-dir dotbot-brew \
		-c "${MAC_CONFIG_PREFIX}${CONFIG_SUFFIX}"
elif [ "$(uname -s)" = "Linux" ]; then
	# If on a Linux machine install VS Code if it isn't already installed.
	setup_vscode
else
	echo ' This should never hit here'
	echo '  ¯\_(ツ)_/¯ '
	exit 1
fi

# Run dotbot with the base configurations.
"${BASEDIR}/${DOTBOT_DIR}/${DOTBOT_BIN}" -d "${BASEDIR}" \
	-c "${BASE_CONFIG_PREFIX}${CONFIG_SUFFIX}"

# Check your current shell. If your active shell is ZSH setup antibody.
case $SHELL in
*/zsh)
	# setup_antibody
	echo ' ZSH setup is good to go. Start a new shell session!'
	;;
*)
	echo ' Activate ZSH!'
	echo '  -> chsh -s =zsh'
	exit 1
esac

setup_docker
setup_go
setup_nvm
setup_starship
