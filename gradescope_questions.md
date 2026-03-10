Coursework 2 - Kubernetes for Cloud and Edge Network Functions
Q1 General information
0 Points
Grading comment:
Briefly describe your coursework. What have you done? 400 characters with spaces max.
-------
The coursework is two implementations of Open5gs, one on K3s to simulate an Edge deployment all running in an Azure VM. The other is a Kubernetes cluster on Azure Kubernetes Service (AKS) to simulate a Cloud deployment.
The goal is to compare the performance of the two implementations and to understand the differences between implementation effort for the two._
-------

Q2 Selection of VNF(s) and Justification
10 Points
Grading comment:
Which VNF(s) did you select, why are they suitable for telecom scenarios, and how do their roles and resource requirements justify your choice? 2500 characters with spaces max.
--------
Open5GS is a C-language Open Source implementation of 5GC and EPC, i.e. the core network of NR/LTE network.
Open5GS is a reference implementation of the 5G Core/EPC architecture.
[Reference](https://open5gs.org/open5gs/features/)
Open5GS implements the major 5G Core components.
It has the following Control Plane Functions
1. AMF	Access & Mobility Management Function – handles UE registration and mobility
2. SMF	Session Management Function – manages PDU sessions
3. NRF	Network Repository Function – service discovery for SBA
4. PCF	Policy Control Function – QoS and policy management
5. UDM	Unified Data Management – subscriber data
6. AUSF	Authentication Server Function – subscriber authentication
7. NSSF	Network Slice Selection Function

And then User Plane Function - UPF	User Plane Function – packet forwarding and data plane processing. 
It seemed that this would be the most suitable for a standalone test.

[Background article discussing testing of UPF](https://www.sciencedirect.com/science/article/abs/pii/S1389128622005692)

#### Why UPF was chosen

UPF handles actual user data traffic between user's equipment,e.g. mobile phone, and external networks. It is the data-plane component, meaning it processes high-throughput packets.

That then gives us the following areas to focus on:
* CPU scheduling
* network stack performance
* container networking (CNI)
* node performance

UPF performance depends heavily on packet processing and kernel networking optimisations, making it a strong candidate for performance experiments.

Metrics to measure

* Throughput (Mbps)
* Packet latency
* CPU utilisation
* Pod scaling behaviour
* Network overhead between clusters

AKS vs K3s

AKS clusters often introduce:
* overlay networking
* Azure load balancers
* virtual NIC layers
* These impact packet forwarding, which the UPF performs continuously.
SCTP

5G NGAP (gNB↔AMF) uses SCTP. Kubernetes supports SCTP for ClusterIP/NodePort, but LoadBalancer SCTP depends on the cloud provider and often isn’t supported.
So the simplest AKS  setup is: run the gNB/UE simulator inside AKS (no need to expose SCTP publicly).
https://learn.microsoft.com/en-us/answers/questions/573521/does-azure-aks-support-sctp-and-how-to-enable-it



Q3 Environment Setup (Cloud vs Edge) & Deployment of VNF(s)
10 Points
Grading comment:
How did you set up the cloud and edge Kubernetes environments, deploy the same VNF(s) in both, and what configuration details, challenges and "hello world" results can you report? 2500 characters with spaces max.


Q4 Experimental Design and Performance Monitoring
10 Points
Grading comment:
Describe the setup of your experiment design and the performance metrics that were measured, including how they were obtained. 2500 characters with spaces max.


Q5 Results and Discussion
10 Points
Grading comment:
Results - in the form of tables and /or graphs. To be uploaded. Discussion of results and contrast with the literature. 3000 characters with spaces max.

Q6 Developed code, scripts, and GenAI troubleshooting
10 Points
Grading comment:
You can either: 1) provide a link to Git, or 2) create a Zip or tar archive of the files which make up your system and upload it here.


Q7 Demo. Video
0 Points
Grading comment:
Short video (maximum 2 minutes long) to demonstrate your solution and results. You can either: 1) upload it here, or 2) upload on any cloud platform of your choice, e.g. YouTube and provide the link.