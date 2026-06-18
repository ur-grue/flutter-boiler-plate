#!/usr/bin/env zsh
# App Factory — entrypoint moved to ./setup.zsh (one script: prereqs + auto-install
# of gum/Flutter/Claude, secrets, Claude config, scaffold, AI /mvp build, all in the
# cyberpunk UI). This shim keeps `./new-app.sh` working and forwards every argument.
set -euo pipefail
exec "${0:A:h}/setup.zsh" "$@"
