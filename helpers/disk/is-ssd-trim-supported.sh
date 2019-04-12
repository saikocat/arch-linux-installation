#!/bin/bash
set -euo pipefail

DRIVE=$1

lsblk --discard -lnd -o name,disc-gran,disc-max ${DRIVE} | grep -v "0B"
