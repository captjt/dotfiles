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

alias l='ls -lFh'     #size,show type,human readable
alias ll='ls -l'      #long list
alias ldot='ls -ld .*'

# mmake >> make: see github.com/tj/mmake
alias make='mmake'
