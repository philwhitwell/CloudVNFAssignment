
RESOURCE_GROUP="AKSOnlyResourceGroup" #" Original =ResourceNorway"
CLUSTER_NAME="AKSCoursework"
NAMESPACE="pw-open5gs"

kubectl -n "pw-open5gs" get pods -l app.kubernetes.io/name=upf -o wide
kubectl -n "pw-open5gs" logs deploy/open5gs-upf --tail=200


helm upgrade --install open5gs oci://registry-1.docker.io/gradiantcharts/open5gs \
  -n pw-open5gs -f yamls/UPF-smf-pfcp-fix.yaml

kubectl -n "pw-open5gs" get svc | grep -i upf
kubectl -n "pw-open5gs" describe svc open5gs-upf-pfcp
#open5gs-upf-gtpu    ClusterIP   10.0.11.37     <none>        2152/UDP            5h28m
#open5gs-upf-pfcp    ClusterIP   10.0.141.128   <none>        8805/UDP            5h28m

#verify registration of ueransim - Abandonned due to same SCTP issue on AKS
#kubectl -n "pw-open5gs" logs deploy/ueransim-gnb --tail=200
#kubectl -n "pw-open5gs" logs deploy/ueransim-gnb-ues  --tail=200

#Directly create the load not using UERANSIM
kubectl -n pw-open5gs patch svc open5gs-upf-gtpu \
  -p '{"spec": {"type": "LoadBalancer"}}'

#NAME               TYPE           CLUSTER-IP   EXTERNAL-IP    PORT(S)          AGE
#open5gs-upf-gtpu   LoadBalancer   10.0.11.37   51.13.23.111   2152:32582/UDP   6h10m

kubectl -n pw-open5gs exec -it deploy/open5gs-upf -- iperf3 -s -p 2152

#Create an iperf server in Kubernetes
kubectl create ns dn

kubectl -n dn run iperf-server \
  --image=networkstatic/iperf3 \
  -- iperf3 -s

kubectl -n dn expose pod iperf-server \
  --port 5201 \
  --target-port 5201

kubectl -n dn get svc iperf-server
#NAME           TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
#iperf-server   ClusterIP   10.0.150.8   <none>        5201/TCP   16s

#now test from UE POD
kubectl -n pw-open5gs get pods | grep ue
#% DN_IP=$(kubectl -n dn get svc iperf-server -o jsonpath='{.spec.clusterIP}')
#echo $DN_IP
#10.0.150.8

#test from UPF pod
kubectl -n pw-open5gs exec -it open5gs-upf-65fd7c9bc7-bhs2n -- bash
#then
iperf3 -s
#test from laptop
iperf3 -c 51.13.23.111 -p 5201

#Install TRex
curl -k -L https://trex-tgn.cisco.com/trex/release/latest -o trex.tar.gz