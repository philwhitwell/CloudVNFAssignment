
#install and test on macbook
brew install iperf3
iperf3 --version

#install on vm
sudo apt update
sudo apt install iperf3 -y

#start it as a server on vm
iperf3 -s  #check port is 5201

#open port on Azure VM
iperf3 -c 51.13.186.89

#add prometheus and grafana on K3s
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack \
-n monitoring \
--create-namespace

kubectl -n monitoring port-forward svc/monitoring-grafana 3000:80
#test in http://localhost:3000

#username: admin
#password: prom-operator

#monitoring open5gs-upf-869b566fd4-cnlp8 in grafana
iperf3 -c 51.13.186.89 -P 10 -t 20 #basic test
iperf3 -c 51.13.186.89 -P 4 -t 20  #4 * parallel streams.
iperf3 -c 51.13.186.89 -u -b 50M -t 20 #UDP 50 megabits per second
iperf3 -c 51.13.186.89 -P 1 -t 20 #Test 1 — medium load
iperf3 -c 51.13.186.89 -P 5 -t 20 #Test 2 — medium load
iperf3 -c 51.13.186.89 -P 10 -t 20 #Test 3 — heavy load


iperf3 -c 51.13.186.89 -u -b 10M -t 60 #Test 1 — Light UDP load
iperf3 -c 51.13.186.89 -u -b 500M -l 256 -P 10 -t 120 #UPFs struggle with high packet-per-second rates.

#+-------------------+
#|   MacBook / Host  |
#| iperf3 client     |
#+---------+---------+
#          |
#          | Internet / external access
#          v
#+-------------------+
#|   Azure VM        |
#| UERANSIM          |
#| - nr-gnb          |
#| - nr-ue           |
#| UE tunnel:        |
#|   uesimtun0       |
#|   10.45.0.3       |
#+---------+---------+
#          |
#          | N2: NGAP / SCTP
#          | N3: GTP-U / UDP 2152
#          v
#+------------------------------+
#|      K3s Edge Cluster        |
#|      Open5GS Core            |
#|                              |
#|  +------------------------+  |
#|  | AMF / SMF / UPF        |  |
#|  |                        |  |
#|  | AMF: control plane     |  |
#|  | SMF: session control   |  |
#|  | UPF: user plane        |  |
#|  +------------------------+  |
#+------------------------------+
#          |
#          | N6 user-plane forwarding
#          v
#+-------------------+
#|   Data Network    |
#|   / Internet      |
#|   / iperf server  |
#| 51.13.186.89:5201 |
#+-------------------+