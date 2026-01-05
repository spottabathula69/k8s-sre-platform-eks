#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../infra/terraform/envs/dev"
terraform init -backend=false
