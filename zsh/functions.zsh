#!/bin/sh

# This will install/upgrade all of the tools I use in my environments for misc
# things.
tools() {
  go get -u github.com/astaxie/bat
  go get -u github.com/tj/mmake/cmd/mmake
}

# Create a new directory and enter it. If cd fails it will emit failure message.
mc () {
  mkdir -p "$@" && cd "$@" || echo 'Failed to make directory.'
}
