#!/bin/sh

# This will install/update the go tools I use in my environments.
gotools() {
  go get -u github.com/golang/dep/cmd/dep
  go get -u golang.org/x/tools/cmd/godoc
  go get -u golang.org/x/tools/cmd/goimports
  go get -u golang.org/x/tools/cmd/gorename
  go get -u golang.org/x/tools/cmd/gotype
  go get -u golang.org/x/tools/cmd/guru
  go get -u github.com/golang/lint/golint
  go get -u github.com/mdempsky/gocode
  go get -u github.com/cweill/gotests/...
  go get -u github.com/dougm/goflymake
  go get -u github.com/kisielk/errcheck
  go get -u github.com/rogpeppe/godef
  go get -u honnef.co/go/tools/cmd/keyify
  go get -u honnef.co/go/tools/cmd/megacheck
}

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

# Get ExternalIPs of all Kubernetes worker nodes.
knip() {
  echo "Kubernetes worker nodes ExternalIPs:"
  echo ""
  kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}' | xargs -n1
}

# Get ExternalIPs of all Kubernetes master nodes.
kmip() {
  echo "Kubernetes master nodes ExternalIPs:"
  echo ""
  kubectl get nodes --selector=kubernetes.io/role==master -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}' | xargs -n1
}

# List all Secrets currently in use by any Kubernetes pod.
kusc() {
  echo "Kubernetes secrets that are used:"
  echo ""
  kubectl get pods -o json | jq '.items[].spec.containers[].env[]?.valueFrom.secretKeyRef.name' | grep -v null | sort | uniq
}
