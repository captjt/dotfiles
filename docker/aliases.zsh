#!/bin/sh

# Remove all containers
drm() {
  local ids count
  ids="$(docker ps -a -q)"
  if [ -z "$ids" ]; then
    echo "No containers to remove"
    return 0
  fi

  count="$(echo "$ids" | wc -l | tr -d ' ')"
  _confirm_action "Remove $count Docker container(s)?" || return 1
  docker rm $ids
}

# Remove all images
drmi() {
  local ids count
  ids="$(docker images -q)"
  if [ -z "$ids" ]; then
    echo "No Docker images to remove"
    return 0
  fi

  count="$(echo "$ids" | sort -u | wc -l | tr -d ' ')"
  _confirm_action "Force remove $count Docker image(s)?" || return 1
  docker rmi --force $(echo "$ids" | sort -u)
}

# Stop all containers
dstop() {
  local ids count
  ids="$(docker ps -a -q)"
  if [ -z "$ids" ]; then
    echo "No containers to stop"
    return 0
  fi

  count="$(echo "$ids" | wc -l | tr -d ' ')"
  _confirm_action "Stop $count Docker container(s)?" || return 1
  docker stop $ids
}

# Stop and remove all containers
drmf() {
  local ids count
  ids="$(docker ps -a -q)"
  if [ -z "$ids" ]; then
    echo "No containers to stop and remove"
    return 0
  fi

  count="$(echo "$ids" | wc -l | tr -d ' ')"
  _confirm_action "Stop and remove $count Docker container(s)?" || return 1
  docker stop $ids
  docker rm $ids
}

# Get latest container ID
alias dl='docker ps -l -q'

# Get process included stop container
alias dpa='docker ps -a'

# Get images
alias di='docker images'

alias dip="docker inspect --format '{{ .NetworkSettings.IPAddress }}'"

# Run container in background, e.g., $dkd base /bin/echo hello
alias dkd='docker run -d -P'

# Run interactive container, e.g., $dki base /bin/bash
alias dki='docker run -i -t -P'

# Execute interactive container, e.g., $dex base /bin/bash
alias dex='docker exec -i -t'

# Remove and prune all docker volumes
dvp() {
  _confirm_action "Run docker system prune --volumes --force --all?" || return 1
  docker system prune --volumes -fa
}

# Tail the logs starting with the latest 50 lines of a container
dtail() {
  docker logs -tf --tail="50" "$@"
}
