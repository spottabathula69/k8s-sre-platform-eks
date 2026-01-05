#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../infra/terraform/envs/dev"
terraform fmt -check -recursive
terraform validate
