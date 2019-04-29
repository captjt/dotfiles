#!/bin/sh
export GOPATH=$HOME/go
export GOBIN=$HOME/go/bin
export CDPATH=$GOPATH/src/github.com
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/go/bin:$GOBIN"

if [ "$(uname -s)" = "Darwin" ]; then
  export GOROOT=/usr/local/opt/go/libexec
elif [ "$(uname -s)" = "Linux" ]; then
  export GOROOT=/usr/local/go
fi

export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GOROOT/bin
export GOTRACEBACK=all # Get all goroutines trace and not just the crashing one
export GO111MODULE=on
