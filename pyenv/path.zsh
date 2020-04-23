#!/bin/sh
export PYENV_DIR="$(pyenv root)"
export PATH="$PYENV_DIR/shims:$PATH"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
[ -s "$PYENV_DIR/completions/pyenv.zsh" ] && \. "$PYENV_DIR/completions/pyenv.zsh"

eval "$(pyenv init -)"
