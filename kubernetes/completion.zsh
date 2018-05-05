#!/usr/bin/env zsh

# If Kubernetes helm tool is installed activate the helm ZSH completion.
#
#  See: https://docs.helm.sh/helm/#helm-completion
if [ $commands[helm] ]; then
  source <(helm completion zsh)
fi

# If the Kubernetes kubectl tool is installed activate the kubectl ZSH
#  completion.
#
#  See: https://kubernetes.io/docs/tasks/tools/install-kubectl/#enabling-shell-autocompletion
if [ $commands[kubectl] ]; then
  source <(kubectl completion zsh)
fi
