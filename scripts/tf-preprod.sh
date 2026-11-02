#!/usr/bin/env bash
# Run Terraform locally against the PreProd environment. Same commands as tf.sh, e.g. ./scripts/tf-preprod.sh plan
ENVIRONMENT=PreProd exec "$(dirname "${BASH_SOURCE[0]}")/tf.sh" "$@"
