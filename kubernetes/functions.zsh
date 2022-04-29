#!/bin/sh

kfl_usage() {
  echo "\
Usage: $0 [ARGS]

Follow logs based on provided selector argument.

Arguments:
  \$1       Selector for pods to follow logs. Format: 'key=value'
  \$2       Optional container name within the pod resource.
"
}

kfl() {
  echo "kubectl follow logs with selector:"
  echo "  provide optional container name (second argument)"
  echo ""

  if [ -z "$1" ]; then
    kfl_usage
    exit 1
  fi

  if [ -z "$2" ]; then
    kubectl logs --prefix --timestamps --selector "$1" --follow
  else
    kubectl logs --prefix --timestamps --selector "$1" --container "$2" --follow
  fi
}

ksl() {
  echo "kubectl logs with selector:"
  echo "  provide optional container name (second argument)"
  echo ""

  if [ -z "$1" ]; then
    echo "Pass in selector key=value"
    exit 1
  fi

  if [ -z "$2" ]; then
    kubectl logs --prefix --timestamps --selector "$1"
  else
    kubectl logs --prefix --timestamps --selector "$1" --container "$2"
  fi
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
