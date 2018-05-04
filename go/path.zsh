#!/bin/sh
export GOPATH=$HOME/go
export GOBIN=$HOME/go/bin
export CDPATH=$GOPATH/src/github.com
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/go/bin:$GOBIN"
export GOROOT=/usr/local/go
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GOROOT/bin
export GOTRACEBACK=all # Get all goroutines trace and not just the crashing one

# Make Python use UTF-8 encoding for output to stdin, stdout, and stderr.
export PYTHONIOENCODING='UTF-8'
