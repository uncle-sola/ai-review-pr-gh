#!/usr/bin/env bash
# Run Terraform locally against the same state as the GitHub workflows, for debugging
# before checking in. Uses your own Azure CLI login (az login) instead of the service principal.
#
#   ./scripts/tf.sh init       # connect to the shared azurerm backend
#   ./scripts/tf.sh plan       # plan and save it as terraform/tfplan
#   ./scripts/tf.sh apply      # apply the saved plan (or plan + apply with a prompt if there is none)
#   ./scripts/tf.sh destroy    # destroy everything in the state (asks for confirmation)
#   ./scripts/tf.sh <other>    # any other terraform command, e.g. "output" or "state list"
#
# Defaults to dev. For other environments use tf-preprod.sh or tf-production.sh, which set
# ENVIRONMENT and call this script; names are derived from it (dev/DEV -> PreProd/PREPROD and so on).
#
# WARNING: this is the same state GitHub deploys to. apply and destroy change the real
# resources, and the next deploy from main will undo any local changes that are not merged.
#
# Settings can be overridden with environment variables of the same name.
set -euo pipefail

ENVIRONMENT="${ENVIRONMENT:-dev}"
ENVIRONMENT_UPPER="$(echo "$ENVIRONMENT" | tr '[:lower:]' '[:upper:]')"
ENVIRONMENT_LOWER="$(echo "$ENVIRONMENT" | tr '[:upper:]' '[:lower:]')" # Storage account names must be lowercase
STATE_RESOURCE_GROUP="${STATE_RESOURCE_GROUP:-TerraformState-${ENVIRONMENT_UPPER}-UKS}"
STATE_STORAGE_ACCOUNT="${STATE_STORAGE_ACCOUNT:-tfstatest${ENVIRONMENT_LOWER}uks}"
STATE_CONTAINER="${STATE_CONTAINER:-tfstates}"
STATE_KEY="${STATE_KEY:-tf/ai-review-pr-gh.tfstate}" # Same key the workflows use
PLAN_FILE="tfplan"

TF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../terraform" && pwd)"
tf() { terraform -chdir="$TF_DIR" "$@"; }

echo "Environment: $ENVIRONMENT  State: $STATE_STORAGE_ACCOUNT/$STATE_CONTAINER/$STATE_KEY" >&2

if ! az account show --output none 2>/dev/null; then
  echo "Not logged in to Azure. Run 'az login' first." >&2
  exit 1
fi

export TF_VAR_environment="$ENVIRONMENT"
# The azurerm provider needs the subscription explicitly; default to the one az is using
export ARM_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID:-$(az account show --query id --output tsv)}"

command="${1:-}"
[ $# -gt 0 ] && shift

case "$command" in
  init)
    tf init -input=false -reconfigure \
      -backend-config="resource_group_name=$STATE_RESOURCE_GROUP" \
      -backend-config="storage_account_name=$STATE_STORAGE_ACCOUNT" \
      -backend-config="container_name=$STATE_CONTAINER" \
      -backend-config="key=$STATE_KEY" \
      "$@"
    ;;
  plan)
    tf plan -input=false -out="$PLAN_FILE" "$@"
    ;;
  apply)
    if [ $# -eq 0 ] && [ -f "$TF_DIR/$PLAN_FILE" ]; then
      tf apply -input=false "$PLAN_FILE"
      rm -f "$TF_DIR/$PLAN_FILE"
    else
      tf apply "$@"
    fi
    ;;
  destroy)
    tf destroy "$@"
    ;;
  "")
    sed -n '2,17p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
    exit 1
    ;;
  *)
    tf "$command" "$@"
    ;;
esac
