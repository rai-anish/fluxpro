#!/bin/bash
set -euo pipefail

cd /home/anish/projects/FluxPro
exec setsid ./Flux/start_flux.sh >/tmp/fluxpro-launch.log 2>&1 < /dev/null
