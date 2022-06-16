#!/usr/bin/env zsh

alias kc='source <(kubectl completion zsh)'

alias kclean='kubectl delete pods -A --field-selector=status.phase=Failed'
