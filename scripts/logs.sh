#!/bin/bash
set -euo pipefail
sudo -u docker-gestor-tickets-es /usr/local/bin/compose-gestor-tickets logs -f --tail=200 "$@"
