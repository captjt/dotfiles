#!/bin/sh

# Remove all containers
alias drm='docker rm $(docker ps -a -q)'

# Remove all images
alias drmi='docker rmi --force $(docker images -q)'

# Stop all containers
alias dstop='docker stop $(docker ps -a -q)'

# Stop and remove all containers
alias drmf='docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)'

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
alias dvp='docker system prune --volumes -fa'
