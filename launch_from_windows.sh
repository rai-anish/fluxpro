#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"
exec setsid ./Flux/start_flux.sh >> /tmp/fluxpro-launch.log 2>&1 < /dev/null
