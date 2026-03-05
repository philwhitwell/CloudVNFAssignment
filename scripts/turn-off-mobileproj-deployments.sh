#!/bin/bash

# ================================

# Configuration

# ================================

BACKEND_NS="mobile-backend"
OPEN5GS_NS="pw-open5gs"

echo "---------------------------------------"
echo "Scaling DOWN mobile-backend deployments"
echo "Namespace: $BACKEND_NS"
echo "---------------------------------------"

# Scale down all deployments in mobile-backend

kubectl scale deployment --all --replicas=0 -n $BACKEND_NS

echo ""
echo "---------------------------------------"
echo "Scaling UP Open5GS workloads"
echo "Namespace: $OPEN5GS_NS"
echo "---------------------------------------"

# Scale up all deployments in pw-open5gs

kubectl scale deployment --all --replicas=1 -n $OPEN5GS_NS

# Scale up statefulsets (MongoDB etc.)

kubectl scale statefulset --all --replicas=1 -n $OPEN5GS_NS

echo ""
echo "---------------------------------------"
echo "Current pod status"
echo "---------------------------------------"

kubectl get pods -n $OPEN5GS_NS
