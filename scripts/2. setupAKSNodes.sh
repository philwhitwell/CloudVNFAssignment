#!/bin/bash
# ========= CONFIG =========
#RESOURCE_GROUP="ResourceNorway"
#CLUSTER_NAME="ProjBackend"
SUBSCRIPTION="Azure for Students"
RESOURCE_GROUP="AKSOnlyResourceGroup" #" Original =ResourceNorway"
CLUSTER_NAME="AKSCoursework"


az version
#brew install helm
kubectl version --client
helm version




###Borrowed from my main AKS script
set_subscription() {

  if [ -n "${SUBSCRIPTION:-}" ]; then
    echo "🔑 Setting sudbscription: $SUBSCRIPTION"
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

need_az_login
set_subscription

#check what is running first
kubectl get nodes

#Create namespace to kep all the Open5GS work
kubectl create namespace pw-open5gs

#Grab the YAML to instruct Helm on which containers are needed
curl -L -o 5gSA-values.yaml \
  https://gradiant.github.io/5g-charts/docs/open5gs-ueransim-gnb/5gSA-values.yaml

#Pull the containers and setup the pods
helm install open5gs oci://registry-1.docker.io/gradiantcharts/open5gs \
  --version 2.3.4 \
  -n pw-open5gs \
  --values yamls/5gSA-values.yaml

kubectl -n pw-open5gs get pods -w

az aks nodepool list \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --output table

#MongoDB pod.0/1 nodes are available: 1 Insufficient cpu -- NOT NEEDED AS RESTARTED WITH DEDICATE Cluster
#az aks nodepool scale \
#  --resource-group "$RESOURCE_GROUP" \
#  --cluster-name "$CLUSTER_NAME" \
#  --name agentpool \
#  --node-count 2
#not enough quota

#AMF Not starting so investigate...
kubectl -n pw-open5gs describe pod open5gs-amf-76b5ddf9d4-mnh6x
kubectl -n pw-open5gs logs open5gs-amf-76b5ddf9d4-mnh6x -c open5gs-amf --previous

#03/05 11:29:05.189: [sock] ERROR: socket create(2:1:132) failed (93:Protocol not supported) (../lib/core/ogs-socket.c:92)
#03/05 11:29:05.189: [sock] ERROR: ogs_sock_socket(family:2 type:1) failed (93:Protocol not supported) (../lib/sctp/ogs-lksctp.c:42)
#03/05 11:29:05.190: [sock] FATAL: ogs_sctp_peer_addr_params: Assertion `sock' failed. (../lib/sctp/ogs-lksctp.c:734)
#03/05 11:29:05.190: [core] FATAL: backtrace() returned 10 addresses (../lib/core/ogs-abort.c:37)
#/opt/open5gs/lib/x86_64-linux-gnu/libogssctp.so.2(ogs_sctp_peer_addr_params+0x91) [0x7f02bf598f7c]
#/opt/open5gs/lib/x86_64-linux-gnu/libogssctp.so.2(ogs_sctp_server+0x1c9) [0x7f02bf5973cd]
#Appears there is an issue with AMF and SCTP, so disable as we don't need to test all features.  It might happy registration..
#https://kubernetes.io/docs/concepts/services-networking/service/#sctp


helm upgrade open5gs oci://registry-1.docker.io/gradiantcharts/open5gs \
  -n pw-open5gs \
  -f yamls/5gSA-values.yaml \
  -f yamls/disable-amf.yaml #No longer need to reduce CPU for mongo -f yamls/reduceMongo.yaml \

#https://gradiant.github.io/5g-charts/open5gs-ueransim-gnb.html  add to give registration and data sessions without SCTP

#helm install ueransim-gnb oci://registry-1.docker.io/gradiant/ueransim-gnb \
#  --version 0.2.6 \
#  -n pw-open5gs \
#  --values https://gradiant.github.io/5g-charts/docs/open5gs-ueransim-gnb/gnb-ues-values.yaml

#Test that webUI up but probably need to test load through api and calling the AKS directly?
kubectl -n pw-open5gs port-forward svc/open5gs-webui 9999:9999

#default login Username: admin
#Password: 1423
#  NOT NEEDED WITH NEW BiGGER CLUSTER
#kubectl scale deployment --all --replicas=1 -n pw-open5gs
#kubectl scale statefulset --all --replicas=1 -n pw-open5gs
#find who is hogging all the CPU
#kubectl get pods -A \
#  -o custom-columns="NS:.metadata.namespace,POD:.metadata.name,CPU:.spec.containers[*].resources.requests.cpu" \
#| sort -k3 -h
#kubectl describe node aks-agentpool-90777304-vmss000005 | sed -n '/Allocated resources:/,/Events:/p'
#
##reduce CPU of metrics server
#kubectl -n kube-system scale deployment metrics-server --replicas=1
#kubectl -n kube-system get deploy metrics-server

# ---------

#set up simple hello NGINX world example to prove all networking working
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx \
  --type=LoadBalancer \
  --port=80
kubectl get svc #once externalip assigned test homepage for nginx returned
curl http://20.100.128.92

#put back the containers for Project Backend when assignment done
az aks update \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CLUSTER_NAME"  \
  --attach-acr FirstDockCont

#Azure Subscription
#     │
#Resource Group
#     │
# AKS Cluster
#     │
# ├── Control Plane (Managed by Azure)
# └── Node Pool (VM Scale Set)
#         │
#       Pods
#         │
#     Containers