#!/usr/bin/env zsh

# Forces zsh to realize new commands
zstyle ':completion:*' completer _oldlist _expand _complete _match _ignored _approximate

# Matches case insensitive for lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pending

# Rehash if command not found (possibly recently installed)
zstyle ':completion:*' rehash true

# Menu if nb items > 2
zstyle ':completion:*' menu select=2
