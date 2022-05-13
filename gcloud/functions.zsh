#!/bin/sh

composer_usage() {
  echo "\
Usage: $0 [ARGS]

Execute airflow CLI commands against Cloud Composer environment.

Arguments:
  \$1       Cloud Composer Environment name within GCP project
  \$2       Location value for Cloud Composer environment (i.e. 'us-east4')
  \$3       Composer Airflow commands to execute (i.e. 'dags -- list-runs -d {{dag_id}}')
"
}

composer() {

  # Do this
  help_wanted() {
    [ "$#" -ge "1" ] && [ "$1" = '-h' ] || [ "$1" = '--help' ] || [ "$1" = "-?" ]
  }

  if help_wanted "$@"; then
    composer_usage
    return
  fi

  first_arg="${1}"
  second_arg="${2}"

  if [ -z "$first_arg" ]; then
    echo "Environment name must be provided."
    composer_usage
    return
  fi

  if [ -z "$second_arg" ]; then
    echo "Location name must be provided."
    composer_usage
    return
  fi

  gcloud composer environments run "$first_arg" --location "$second_arg" "${@:3}"
}
