#!/usr/bin/env bash
# This script assumes you already have git configured.

set -e

# Shortcut to this dotfiles path is $DOTFILES
export DOTFILES="$HOME/.dotfiles"

# Setup and configure antidote.
# Project page: https://github.com/mattmc3/antidote
setup_antidote() {
	command -v antidote >/dev/null && {
		antidote bundle < "$HOME/.dotfiles/antibody/bundles.txt" > ~/.zsh_plugins.zsh
		antidote update
		return
	}

	if command -v brew >/dev/null 2>&1; then
		brew install antidote || brew upgrade antidote
	else
		echo "Homebrew is required to install antidote automatically."
		return 0
	fi

	antidote bundle < "$HOME/.dotfiles/antibody/bundles.txt" > ~/.zsh_plugins.zsh
	antidote update
}

setup_nvm() {
	command -v nvm >/dev/null && return

	NVM_VERSION="v0.39.5"

	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/"$NVM_VERSION"/install.sh | bash
}

backup_existing_path() {
	local path="$1"
	local backup_path

	backup_path="$path.backup.$(date +%Y%m%d%H%M%S)"

	mv "$path" "$backup_path"
	echo " Backed up existing $path to $backup_path"
}

prepare_link_path() {
	local path="$1"

	if [ -L "$path" ] || [ ! -e "$path" ]; then
		return
	fi

	if [ -f "$path" ] && [ ! -s "$path" ]; then
		rm "$path"
		return
	fi

	if [ -d "$path" ] && [ -z "$(find "$path" -mindepth 1 -maxdepth 1 -print -quit)" ]; then
		rmdir "$path"
		return
	fi

	backup_existing_path "$path"
}

prepare_codex_agents_link() {
	local codex_dir="$HOME/.codex"
	local agents_file="$codex_dir/AGENTS.md"

	mkdir -p "$codex_dir"
	prepare_link_path "$agents_file"
}

prepare_global_agent_skills_links() {
	prepare_link_path "$HOME/.agents"
}

link_global_agent_skills_to_consumers() {
	local skills_dir="$HOME/.agents/skills"
	local consumer_dir
	local consumer_parent
	local skill_path
	local skill_name
	local link_path
	local consumer_dirs=(
		"$HOME/.codex/skills"
		"$HOME/.claude/skills"
		"$HOME/.factory/skills"
	)

	[ -d "$skills_dir" ] || return

	for consumer_dir in "${consumer_dirs[@]}"; do
		consumer_parent="$(dirname "$consumer_dir")"
		[ -d "$consumer_parent" ] || continue

		mkdir -p "$consumer_dir"

		for skill_path in "$skills_dir"/*; do
			[ -d "$skill_path" ] || continue

			skill_name="$(basename "$skill_path")"
			link_path="$consumer_dir/$skill_name"

			if [ -L "$link_path" ]; then
				continue
			fi

			if [ -e "$link_path" ]; then
				backup_existing_path "$link_path"
			fi

			ln -s "$skill_path" "$link_path"
		done
	done
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
		brew install --cask visual-studio-code
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

setup_agent_skills() {
	cd "${BASEDIR}"
	git submodule update --init --recursive "${DOTBOT_DIR}"
	prepare_codex_agents_link
	prepare_global_agent_skills_links

	"${BASEDIR}/${DOTBOT_DIR}/${DOTBOT_BIN}" -d "${BASEDIR}" \
		-c "agents${CONFIG_SUFFIX}"
	link_global_agent_skills_to_consumers
}

if [ "${1:-}" = "--agent-skills" ]; then
	setup_agent_skills
	exit 0
fi

# Update submodules and bootstrap with dotbot. If running on OSX install all
#  brews from Brewfile.
cd "${BASEDIR}"
git submodule update --init --recursive "${DOTBOT_DIR}"
prepare_codex_agents_link
prepare_global_agent_skills_links

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
link_global_agent_skills_to_consumers

# Check your current shell. If your active shell is ZSH setup antibody.
case $SHELL in
*/zsh)
	setup_antidote
	echo ' ZSH setup is good to go. Start a new shell session!'
	;;
*)
	echo ' Activate ZSH!'
	echo '  -> chsh -s =zsh'
	exit 1
esac

# setup_docker
# setup_go
setup_nvm
setup_starship
