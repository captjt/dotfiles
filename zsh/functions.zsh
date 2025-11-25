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
  local env=$1

  # Validate input
  if [[ -z "$env" ]]; then
    echo "Usage: gke_connect [environment]"
    _gke_show_available_environments
    return 1
  fi

  # Check if configuration is set
  if [[ -z "$GKE_ENVIRONMENTS" ]]; then
    echo "❌ GKE_ENVIRONMENTS not configured. Please set your environment configuration."
    echo "Example: export GKE_ENVIRONMENTS=\"dev:my-project-dev:8881,staging:my-project-stage:8882\""
    return 1
  fi

  # Parse environments from configuration (bash/zsh compatible)
  local found=false
  local config_list="$GKE_ENVIRONMENTS"

  while [[ -n "$config_list" ]]; do
    local config="${config_list%%,*}"                   # Get first item
    config_list="${config_list#*,}"                     # Remove first item
    [[ "$config" == "$config_list" ]] && config_list="" # Handle last item

    IFS=':' read -r name project port <<<"$config"

    if [[ "$env" == "$name" ]]; then
      found=true
      echo "🔗 Connecting to $name environment..."

      # Check if proxy is already running for this port
      if pgrep -f "L${port}:127.0.0.1:8888" >/dev/null; then
        echo "📡 Proxy already running on port $port"
      else
        echo "🚀 Starting proxy for $name on port $port..."

        # Start proxy in background
        gcloud beta compute ssh "$GKE_BASTION_HOST" \
          --tunnel-through-iap \
          --project "$project" \
          --zone "$GKE_BASTION_ZONE" \
          -- -L${port}:127.0.0.1:8888 -N &

        # Store PID for cleanup
        echo $! >"/tmp/gke_proxy_${name}.pid"

        # Wait for proxy to establish
        echo "⏳ Waiting for proxy to establish..."
        sleep 4

        # Verify proxy is working
        if ! pgrep -f "L${port}:127.0.0.1:8888" >/dev/null; then
          echo "❌ Failed to start proxy"
          return 1
        fi
      fi

      # Check if kubectl context already exists
      local context_name="gke_${project}_${GKE_CLUSTER_REGION}_${GKE_CLUSTER_NAME}"
      if kubectl config get-contexts -o name | grep -q "^${context_name}$"; then
        echo "📋 Using existing kubectl context: $context_name"
        kubectl config use-context "$context_name"
      else
        echo "📋 Creating new kubectl context..."
        # Get credentials WITHOUT proxy (gcloud doesn't need it for this)
        gcloud container clusters get-credentials \
          --project "$project" \
          --region "$GKE_CLUSTER_REGION" \
          --internal-ip \
          "$GKE_CLUSTER_NAME"

        # Rename context for easier identification
        kubectl config rename-context "$context_name" "gke-$name" 2>/dev/null || true
      fi

      # Set proxy environment AFTER getting credentials
      export HTTPS_PROXY="http://localhost:${port}"
      echo "🌐 Set HTTPS_PROXY to http://localhost:${port}"

      # Verify connection
      echo "🔍 Testing connection..."
      if kubectl cluster-info --request-timeout=10s >/dev/null 2>&1; then
        echo "✅ Successfully connected to $name environment!"
        echo "📊 Current context: $(kubectl config current-context)"
        echo ""
        echo "You can now use kubectl commands for the $name environment"
        echo "To disconnect, run: gke_disconnect"
      else
        echo "❌ Failed to connect to cluster. Check your proxy and credentials."
        return 1
      fi

      break
    fi
  done

  if [[ "$found" == false ]]; then
    echo "❌ Unknown environment: $env"
    _gke_show_available_environments
    return 1
  fi
}

# Helper function to disconnect and cleanup
gke_disconnect() {
  echo "🧹 Cleaning up GKE connections..."

  # Parse environments to get all possible env names
  if [[ -n "$GKE_ENVIRONMENTS" ]]; then
    local config_list="$GKE_ENVIRONMENTS"

    while [[ -n "$config_list" ]]; do
      local config="${config_list%%,*}"                   # Get first item
      config_list="${config_list#*,}"                     # Remove first item
      [[ "$config" == "$config_list" ]] && config_list="" # Handle last item

      IFS=':' read -r name project port <<<"$config"
      local pid_file="/tmp/gke_proxy_${name}.pid"
      if [[ -f "$pid_file" ]]; then
        local pid=$(cat "$pid_file")
        if kill "$pid" 2>/dev/null; then
          echo "🔌 Stopped proxy for $name (PID: $pid)"
        fi
        rm "$pid_file"
      fi
    done
  fi

  # Also kill any remaining SSH tunnels (backup cleanup)
  if [[ -n "$GKE_BASTION_HOST" ]]; then
    pkill -f "gcloud.*compute.*ssh.*${GKE_BASTION_HOST}.*-L.*:127.0.0.1:8888" 2>/dev/null || true
  fi

  # Clear proxy environment
  unset HTTPS_PROXY
  echo "🌐 Cleared HTTPS_PROXY"

  echo "✅ Disconnected from all GKE environments"
}

# Helper function to show current status
gke_status() {
  echo "📊 GKE Connection Status:"
  echo "------------------------"

  # Show configuration
  echo "🔧 Configuration:"
  echo "   Bastion Host: $GKE_BASTION_HOST"
  echo "   Bastion Zone: $GKE_BASTION_ZONE"
  echo "   Cluster Name: $GKE_CLUSTER_NAME"
  echo "   Cluster Region: $GKE_CLUSTER_REGION"
  echo ""

  # Check proxy status
  local has_proxy=false
  if [[ -n "$GKE_ENVIRONMENTS" ]]; then
    local config_list="$GKE_ENVIRONMENTS"

    while [[ -n "$config_list" ]]; do
      local config="${config_list%%,*}"                   # Get first item
      config_list="${config_list#*,}"                     # Remove first item
      [[ "$config" == "$config_list" ]] && config_list="" # Handle last item

      IFS=':' read -r name project port <<<"$config"
      if pgrep -f "L${port}:127.0.0.1:8888" >/dev/null; then
        echo "📡 Proxy running for $name on port $port"
        has_proxy=true
      fi
    done
  fi

  if [[ "$has_proxy" == false ]]; then
    echo "📡 No active proxies"
  fi

  # Check HTTPS_PROXY
  if [[ -n "$HTTPS_PROXY" ]]; then
    echo "🌐 HTTPS_PROXY: $HTTPS_PROXY"
  else
    echo "🌐 HTTPS_PROXY: not set"
  fi

  # Check current kubectl context
  local current_context=$(kubectl config current-context 2>/dev/null || echo "none")
  echo "📋 Current kubectl context: $current_context"

  # Test connectivity if proxy is active
  if [[ -n "$HTTPS_PROXY" ]]; then
    echo "🔍 Testing cluster connectivity..."
    if kubectl cluster-info --request-timeout=5s >/dev/null 2>&1; then
      echo "✅ Cluster connection: OK"
    else
      echo "❌ Cluster connection: Failed"
    fi
  fi
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
