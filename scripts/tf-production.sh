#!/usr/bin/env bash
# Run Terraform locally against the Production environment. Same commands as tf.sh, e.g. ./scripts/tf-production.sh plan
ENVIRONMENT=Production exec "$(dirname "${BASH_SOURCE[0]}")/tf.sh" "$@"
