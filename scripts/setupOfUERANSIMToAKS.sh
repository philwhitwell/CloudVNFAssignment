#give an external ip to AMF so can point UERANSIM to it
kubectl patch svc open5gs-amf-ngap -n pw-open5gs \
  -p '{"spec": {"type": "LoadBalancer"}}'

kubectl run iperf3-server \
  --image=networkstatic/iperf3 \
  --restart=Never \
  -n pw-open5gs \
  -- iperf3 -s

kubectl expose pod iperf3-server \
  --port=5201 \
  --target-port=5201 \
  --name=iperf3-service \
  -n pw-open5gs

#test from VM
iperf3 -c 20.100.38.129 -t 60

