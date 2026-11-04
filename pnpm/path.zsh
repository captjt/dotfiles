#!/bin/sh
export PNPM_HOME="$HOME/Library/pnpm"

# pnpm itself lives in $PNPM_HOME; since pnpm 11, global package bins are
# linked into $PNPM_HOME/bin.
export PATH="$PNPM_HOME/bin:$PNPM_HOME:$PATH"
