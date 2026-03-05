#### Open5GS (5GC/EPC)?? NOT SELECTED AS NOTHING EASY IN Azure Kubernetes Service

Role in telecom:
Open5GS is a C-language Open Source implementation of 5GC and EPC, i.e. the core network of NR/LTE network.
Open5GS is a reference implementation of the 5G Core/EPC architecture.
[Reference](https://open5gs.org/open5gs/features/)
[Open5GS](https://open5gs.org/)
Why it’s a good Kubernetes VNF choice
[Tutorial](https://dev.to/infinitydon/virtual-4g-simulation-using-kubernetes-and-gns3-3b7)

+ KubeEDGE ???


1. #### Open5GS (Cloud-Native 5G Core / VNF)

2. Overview

Open5GS was selected as the primary VNF because it provides a complete open-source implementation of the 5G core network aligned with 3GPP standards and supports container-native deployment on Kubernetes platforms, 
enabling realistic telecom network experimentation within manageable computational resources.

4G LTE EPC

5G Standalone (SA) Core

[Documentation](Open5GS)

2. Open5GS Network Functions

Open5GS implements the major 3GPP 5G Core components.

Control Plane Functions
Function	Role
AMF	Access & Mobility Management Function – handles UE registration and mobility
SMF	Session Management Function – manages PDU sessions
NRF	Network Repository Function – service discovery for SBA
PCF	Policy Control Function – QoS and policy management
UDM	Unified Data Management – subscriber data
AUSF	Authentication Server Function – subscriber authentication
NSSF	Network Slice Selection Function
User Plane Function
Function	Role
UPF	User Plane Function – packet forwarding and data plane processing

https://www.sciencedirect.com/science/article/abs/pii/S1389128622005692
Choose UPF 

[Nice diagram](https://www.researchgate.net/figure/MEC-Architecture-with-User-Plane-Function-UPF-and-Session-Management-Function-SMF_fig2_338947821)

#### Why UPF is ideal

UPF handles actual user data traffic (GTP-U packets) between UE and external networks. It is the data-plane component, meaning it processes high-throughput packets.

Very sensitive to:
* CPU scheduling
* network stack performance
* container networking (CNI)
* node performance

UPF performance depends heavily on packet processing and kernel networking optimisations, making it a strong candidate for performance experiments.

Metrics to measure

* Throughput (Mbps / Gbps)
* Packet latency
* CPU utilisation
* Pod scaling behaviour
* Network overhead between clusters

AKS vs MicroK8s

AKS clusters often introduce:
* overlay networking
* Azure load balancers
* virtual NIC layers
* These impact packet forwarding, which the UPF performs continuously.