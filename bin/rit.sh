#!/bin/sh
set -e

SELF=$(readlink "$0" || true)
if [ -z "$SELF" ]; then SELF="$0"; fi
RELEASE_ROOT="$(cd "$(dirname "$SELF")/.." && pwd -P)"
export RELEASE_ROOT
export RELEASE_VSN="${RELEASE_VSN:-"$(cut -d' ' -f2 "$RELEASE_ROOT/releases/start_erl.data")"}"
REL_VSN_DIR="$RELEASE_ROOT/releases/$RELEASE_VSN"
export RELEASE_BOOT_SCRIPT_CLEAN="${RELEASE_BOOT_SCRIPT_CLEAN:-"start_clean"}"

exec "$REL_VSN_DIR/elixir" \
     --boot "$REL_VSN_DIR/$RELEASE_BOOT_SCRIPT_CLEAN" \
     --boot-var RELEASE_LIB "$RELEASE_ROOT/lib" \
     --eval "RitCLI.parse_and_exec \"`echo $@`\""
