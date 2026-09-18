#!/usr/bin/env bash
set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "Run as root. Bye."; exit 1; }
source ./lib/std.sh

pre_flight || exit 1

log_ok "Pre-flight in order."
