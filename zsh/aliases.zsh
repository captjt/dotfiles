#!/bin/sh

# Show local ip:
alias localip="ipconfig getifaddr en0"

# Bell when the program is finished. It is useful for some
# time-consuming operations. Like:
# > npm install | a
alias a="terminal-notifier -sound default"

# Lock the screen (when going AFK)
alias afk="/System/Library/CoreServices/Menu\\ Extras/User.menu/Contents/Resources/CGSession -suspend"

# Copy public key to clipboard:
alias pubkey="cat ~/.ssh/id_rsa.pub | pbcopy | echo '-> Public key copied to pasteboard.'"

# Use eza and lsd for enhanced file navigation
alias ls='lsd'
alias l='eza --color=always --color-scale=all --color-scale-mode=gradient --icons=always --group-directories-first'
alias ll='eza --color=always --color-scale=all --color-scale-mode=gradient --icons=always --group-directories-first -l --git -h'
alias la='eza --color=always --color-scale=all --color-scale-mode=gradient --icons=always --group-directories-first -a'
alias lla='eza --color=always --color-scale=all --color-scale-mode=gradient --icons=always --group-directories-first -a -l --git -h'
alias ldot='ls -ld .*'
alias lt='lsd --tree'

# nvim >> vim: see neovim.io
alias vim='nvim'

# Use bat instead of cat
alias cat='bat --paging=never'
alias catp='bat' # With paging
