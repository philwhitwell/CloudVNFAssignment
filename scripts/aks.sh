#!/bin/bash
set -euo pipefail

# ========= CONFIG =========
RESOURCE_GROUP="AKSOnlyResourceGroup" #" Original =ResourceNorway"
CLUSTER_NAME="AKSCoursework" #" Original =# ProjBackend"
SUBSCRIPTION="Azure for Students"   # optional: leave "" to use default subscription

usage() {
  cat <<'EOF'
Usage:
  ./aks.sh up        Start AKS cluster, wait until Running, fetch credentials, wait for nodes
  ./aks.sh down      Stop AKS cluster, wait until Stopped
  ./aks.sh status    Show AKS power state + nodes/pods (if kubectl is configured)
EOF
}

need_az_login() {
  if ! az account show >/dev/null 2>&1; then
    echo "❌ Not logged into Azure. Running az login..."
    az login >/dev/null
  fi
}

set_subscription() {
  if [ -n "${SUBSCRIPTION:-}" ]; then
    echo "🔑 Setting subscription: $SUBSCRIPTION"
    az account set --subscription "$SUBSCRIPTION"
  fi
}

aks_state() {
  az aks show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$CLUSTER_NAME" \
    --query "powerState.code" -o tsv 2>/dev/null || echo "Unknown"
}

wait_for_state() {
  local desired="$1"
  echo "⏳ Waiting for AKS to be $desired..."
  while true; do
    local state
    state="$(aks_state)"
    echo "Current state: $state"
    if [ "$state" = "$desired" ]; then
      break
    fi
    sleep 15
  done
}

cmd_up() {
  echo "🚀 Starting AKS cluster: $CLUSTER_NAME"
  echo "--------------------------------------"

  need_az_login
  set_subscription

  echo "🟡 Starting AKS cluster..."
  az aks start --resource-group "$RESOURCE_GROUP" --name "$CLUSTER_NAME"

  wait_for_state "Running"
  echo "✅ AKS cluster is RUNNING"

  echo "🔗 Getting kubectl credentials..."
  az aks get-credentials --resource-group "$RESOURCE_GROUP" --name "$CLUSTER_NAME" --overwrite-existing

  echo "⏳ Waiting for nodes to be Ready..."
  while true; do
    local ready
    ready="$(kubectl get nodes --no-headers 2>/dev/null | grep -c " Ready" || true)"
    if [ "${ready:-0}" -gt 0 ]; then
      break
    fi
    echo "Waiting for nodes..."
    sleep 10
  done

  echo "🎉 Cluster is fully ready!"
  echo "----------------------------"
  kubectl get nodes
  kubectl get pods -A
}

cmd_down() {
  echo "🛑 Stopping AKS cluster: $CLUSTER_NAME"
  echo "--------------------------------------"

  need_az_login
  set_subscription

  echo "🟡 Stopping AKS cluster..."
  az aks stop --resource-group "$RESOURCE_GROUP" --name "$CLUSTER_NAME"

  wait_for_state "Stopped"
  echo "💤 AKS cluster is now STOPPED"
  echo "--------------------------------------"
}

cmd_status() {
  need_az_login
  set_subscription

  echo "AKS: $CLUSTER_NAME (RG: $RESOURCE_GROUP)"
  echo "Power state: $(aks_state)"

  if kubectl get nodes >/dev/null 2>&1; then
    echo "----------------------------"
    kubectl get nodes
    echo "----------------------------"
    kubectl get pods -A
  else
    echo "kubectl not configured for this cluster (run: ./aks.sh up, or az aks get-credentials ...)"
  fi
}

main() {
  local action="${1:-}"
  case "$action" in
    up) cmd_up ;;
    down|stop) cmd_down ;;
    status) cmd_status ;;
    -h|--help|"") usage; exit 0 ;;
    *)
      echo "❌ Unknown command: $action"
      usage
      exit 1
      ;;
  esac
}

main "$@"
