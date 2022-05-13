#!/bin/sh

# Start Bigtable emulator locally.
alias bigtable='gcloud beta emulators bigtable start'

# Set your environment variable automatically for the local Bigtable emulator.
alias bigtable-env-init='gcloud beta emulators bigtable env-init'
