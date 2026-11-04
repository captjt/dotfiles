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

# Generic GKE Connect Functions for Private Clusters via Bastion Hosts
#
# Configuration via environment variables:
# Set these in your shell profile or a separate config file
#
# Example configuration:
# export GKE_BASTION_HOST="my-cluster-bastion"
# export GKE_BASTION_ZONE="us-east4-a"
# export GKE_CLUSTER_NAME="my-cluster"
# export GKE_CLUSTER_REGION="us-east4"
# export GKE_ENVIRONMENTS="dev:my-project-dev:8881,staging:my-project-stage:8882,prod:my-project-prod:8883"

# Default configuration (override these in your shell profile)
GKE_BASTION_HOST=${GKE_BASTION_HOST:-"cluster-bastion"}
GKE_BASTION_ZONE=${GKE_BASTION_ZONE:-"us-east4-a"}
GKE_CLUSTER_NAME=${GKE_CLUSTER_NAME:-"cluster"}
GKE_CLUSTER_REGION=${GKE_CLUSTER_REGION:-"us-east4"}
GKE_ENVIRONMENTS=${GKE_ENVIRONMENTS:-"dev:project-dev:8881,staging:project-stage:8882,prod:project-prod:8883"}

gke_connect() {
  local env=$1 context_name cluster_name port

  if [[ -z "$env" ]]; then
    echo "Usage: gke_connect [environment]"
    _gke_show_available_environments
    return 1
  fi

  if ! gke-tunnel ensure "$env"; then
    echo "❌ Failed to establish the $env bastion tunnel"
    return 1
  fi

  context_name="gke-$env"
  if ! kubectl config get-contexts -o name | grep -qx "$context_name"; then
    echo "❌ Missing kubectl context: $context_name"
    echo "Run gcloud container clusters get-credentials for this environment first."
    return 1
  fi

  port=$(gke-tunnel port "$env") || return 1
  cluster_name=$(kubectl config view --context "$context_name" --minify \
    -o jsonpath='{.contexts[0].context.cluster}') || return 1

  kubectl config set-cluster "$cluster_name" \
    --proxy-url="http://127.0.0.1:$port" >/dev/null || return 1
  kubectl config use-context "$context_name" >/dev/null || return 1

  echo "🔍 Testing $env cluster connection..."
  if kubectl --context "$context_name" cluster-info --request-timeout=10s >/dev/null 2>&1; then
    echo "✅ Connected to $env using context $context_name"
    echo "🌐 Cluster proxy: http://127.0.0.1:$port"
  else
    echo "❌ Failed to connect to $env. Check gke-tunnel status $env."
    return 1
  fi
}

# Helper function to disconnect and cleanup
gke_disconnect() {
  local env=${1:-all} entry name project port
  gke-tunnel stop "$env" || return 1

  # Clean up proxy state left by the older implementation without touching an
  # unrelated user-configured proxy.
  for entry in ${(s:,:)GKE_ENVIRONMENTS}; do
    IFS=: read -r name project port <<<"$entry"
    if [[ "$HTTPS_PROXY" == "http://localhost:$port" ||
          "$HTTPS_PROXY" == "http://127.0.0.1:$port" ]]; then
      unset HTTPS_PROXY
      break
    fi
  done
}

# Helper function to show current status
gke_status() {
  k8s-mcp-status
  echo "Current kubectl context: $(kubectl config current-context 2>/dev/null || echo none)"
}

# Helper function to show available environments
_gke_show_available_environments() {
  if [[ -n "$GKE_ENVIRONMENTS" ]]; then
    echo "Available environments:"
    local config_list="$GKE_ENVIRONMENTS"

    while [[ -n "$config_list" ]]; do
      local config="${config_list%%,*}"                   # Get first item
      config_list="${config_list#*,}"                     # Remove first item
      [[ "$config" == "$config_list" ]] && config_list="" # Handle last item

      IFS=':' read -r name project port <<<"$config"
      echo "  - $name (project: $project, port: $port)"
    done
  else
    echo "No environments configured. Set GKE_ENVIRONMENTS variable."
  fi
}

# Helper function to show configuration template
gke_config_template() {
  echo "# GKE Connect Configuration Template"
  echo "# Add these to your shell profile (.bashrc, .zshrc, etc.)"
  echo ""
  echo "# Basic cluster configuration"
  echo "export GKE_BASTION_HOST=\"your-bastion-host-name\""
  echo "export GKE_BASTION_ZONE=\"us-east4-a\""
  echo "export GKE_CLUSTER_NAME=\"your-cluster-name\""
  echo "export GKE_CLUSTER_REGION=\"us-east4\""
  echo ""
  echo "# Environment configuration (env_name:project_id:local_port)"
  echo "export GKE_ENVIRONMENTS=\"dev:my-project-dev:8881,staging:my-project-stage:8882,prod:my-project-prod:8883\""
  echo ""
  echo "# Optional: Create environment-specific configurations"
  echo "# For multiple clusters, you can create separate config functions:"
  echo "#"
  echo "# setup_project_config() {"
  echo "#     export GKE_BASTION_HOST=\"project-cluster-bastion\""
  echo "#     export GKE_BASTION_ZONE=\"us-east4-a\""
  echo "#     export GKE_CLUSTER_NAME=\"project-cluster\""
  echo "#     export GKE_CLUSTER_REGION=\"us-east4\""
  echo "#     export GKE_ENVIRONMENTS=\"dev:project-dev:8881,staging:project-stage:8882,prod:project-prod:8883\""
  echo "# }"
  echo "#"
  echo "# setup_other_project_config() {"
  echo "#     export GKE_BASTION_HOST=\"other-bastion\""
  echo "#     # ... other config"
  echo "# }"
}

# Extract any archive
extract() {
  if [ ! -f "$1" ]; then
    echo "'$1' is not a valid file"
    return 1
  fi
  case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz)  tar xzf "$1" ;;
    *.tar.xz)  tar xJf "$1" ;;
    *.bz2)     bunzip2 "$1" ;;
    *.gz)      gunzip "$1" ;;
    *.tar)     tar xf "$1" ;;
    *.tbz2)    tar xjf "$1" ;;
    *.tgz)     tar xzf "$1" ;;
    *.zip)     unzip "$1" ;;
    *.Z)       uncompress "$1" ;;
    *.7z)      7z x "$1" ;;
    *.rar)     unrar x "$1" ;;
    *) echo "'$1' cannot be extracted" ;;
  esac
}

# Find process using a port
port() {
  lsof -i ":${1}" | grep LISTEN
}

# Quick git commit
gc() {
  git commit -m "$*"
}

# Reload shell config
reload() {
  source ~/.zshrc
  echo "Shell config reloaded"
}

# Show PATH entries one per line
path() {
  echo $PATH | tr ':' '\n'
}

_confirm_action() {
  local prompt="${1:-Continue?}"
  local reply

  printf "%s [y/N] " "$prompt"
  read -r reply
  [[ "$reply" == [yY] || "$reply" == [yY][eE][sS] ]]
}
