#!/usr/bin/bash
set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "Run as root. Bye."; exit 1; }
source ./lib/std.sh

if ! pre_flight; then
	log_err "$LAST_ERROR"
	exit 1
fi
log_ok "Pre-flight in order."
