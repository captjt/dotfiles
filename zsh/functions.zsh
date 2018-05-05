#!/bin/sh

# This will install or update the go tools I use in my environments.
gotools() {
  echo ' Installing Go tools'
  echo ' -> go dep'
  go get -u github.com/golang/dep/cmd/dep

  echo ' -> godoc'
  go get -u golang.org/x/tools/cmd/godoc

  echo ' -> goimports'
  go get -u golang.org/x/tools/cmd/goimports

  echo ' -> gorename'
  go get -u golang.org/x/tools/cmd/gorename

  echo ' -> gotype'
  go get -u golang.org/x/tools/cmd/gotype

  echo ' -> guru'
  go get -u golang.org/x/tools/cmd/guru

  echo ' -> golint'
  go get -u github.com/golang/lint/golint

  echo ' -> gocode'
  go get -u github.com/nsf/gocode

  echo ' -> gotests'
  go get -u github.com/cweill/gotests/...

  echo ' -> goflymake'
  go get -u github.com/dougm/goflymake

  echo ' -> errcheck'
  go get -u github.com/kisielk/errcheck

  echo ' -> godef'
  go get -u github.com/rogpeppe/godef

  echo ' -> keyify'
  go get honnef.co/go/tools/cmd/keyify
}

# Create a new directory and enter it. If cd fails it will emit failure message.
mc () {
  mkdir -p "$@" && cd "$@" || echo 'Failed to make directory.'
}