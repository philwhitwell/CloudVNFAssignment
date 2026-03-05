#!/bin/bash

# ================================

# Configuration

# ================================


###Borrowed from my main AKS script
set_subscription() {

  if [ -n "${SUBSCRIPTION:-}" ]; then
    echo "🔑 Setting subscription: $SUBSCRIPTION"
    az account set --subscription "$SUBSCRIPTION"
  fi
}
need_az_login() {
  if ! az account show >/dev/null 2>&1; then
    echo "❌ Not logged into Azure. Running az login..."
    az login >/dev/null
  fi
}
###--------

set_subscription
need_az_login

az group create \
  --name AKSOnlyResourceGroup \
  --location norwayeast   #It seems that the only region that works is norwayeast -random

az aks create \
  --resource-group AKSOnlyResourceGroup \
  --name AKSCoursework \
  --location norwayeast \
  --node-count 2 \
  --node-vm-size Standard_B2s_v2 \
  --generate-ssh-keys
  #Tried with a standard Standard_B2s but only certain vms allowed in Norwary East, freed resources by removing a VM, then sized to get two nodes each with 2 vCPUs

#Hit an error that there was not enough vCPUs left so had to clear out from previous labs
az vm list -d -o table
az vm deallocate --name NorwayVM2 --resource-group RESOURCENORWAY

az aks list -o table
#Deleted the first too small cluster to make room for 2 node x 2vCPU
az aks delete \
  --resource-group ResourceNorway \
  --name ProjBackend

#connect the cluster to kubectl
az aks get-credentials \
  --resource-group AKSOnlyResourceGroup \
  --name AKSCoursework

#check that working
kubectl get nodes