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

# lsd >> ls: see github.com/Peltoche/lsd
alias ls='lsd'
alias l='ls -laFh'
alias ll='ls -l'
alias la='ls -la'
alias ldot='ls -ld .*'
alias lt='ls --tree'

# nvim >> vim: see neovim.io
alias vim='nvim'
