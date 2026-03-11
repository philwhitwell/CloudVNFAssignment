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
Which VNF(s) did you select, why are they suitable for telecom scenarios, 
and how do their roles and resource requirements justify your choice? 2500 characters with spaces max.
--------
Open5GS was selected as the Virtual Network Function platform because it provides an open-source implementation of the 5G Core (5GC) and LTE EPC architecture. Within this framework, the User Plane Function (UPF) was chosen for experimentation because it represents the data-plane component responsible for forwarding user traffic, making it ideal for evaluating performance characteristics of cloud and edge Kubernetes environments.

[Reference](https://open5gs.org/open5gs/features/)
Open5GS is a C-language Open Source implementation of 5GC and EPC, i.e. the core network of NR/LTE network.
Open5GS is a reference implementation of the 5G Core/EPC architecture.

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

The UPF handles actual user data traffic between user equipment (UE) such as mobile phones and external networks.
It is the data-plane component of the 5G core network, meaning it processes high-throughput packet flows.

In real telecom deployments the UPF is often deployed close to the network edge to minimise latency and improve throughput for services such as video streaming, web access and IoT communication. This makes it a strong candidate for experiments comparing edge and cloud-based deployments.
Because the UPF continuously processes user traffic, its behaviour can be measured using infrastructure metrics.

This gives the following metrics to compare between the Azure Kubernetes Service (Cloud) and K3s (Edge) implementations:
* CPU utilisation
* Network performance (receive and transmit throughput)
* Memory utilisation
* Overall node performance

UPF performance depends heavily on packet processing efficiency and kernel networking optimisation, making it a strong candidate for performance experiments in containerised environments.

#### Resource requirements

The UPF has significant resource requirements because it performs continuous packet forwarding and tunnelling operations (GTP-U). 
Performance is therefore strongly influenced by:
* CPU availability for packet processing
* Network throughput and latency
* Kernel networking and NIC performance
* Memory usage for session state and buffering
These characteristics make the UPF particularly suitable for evaluating Virtual Network Function performance on Kubernetes platforms.

#### AKS vs K3s
Cloud environments such as Azure Kubernetes Service introduce additional networking layers such as overlay networking, Azure load balancers and virtual NIC abstractions. These layers can impact packet forwarding performance, which the UPF performs continuously.
During deployment, limitations were also encountered with Kubernetes networking support. Certain 5G control-plane components rely on SCTP, which is not fully supported by Kubernetes LoadBalancer services.
https://kubernetes.io/docs/concepts/services-networking/service/#sctp.

To simplify the experiment and focus on measurable data-plane behaviour, the UPF was selected as the primary Virtual Network Function, allowing performance comparison between a cloud Kubernetes platform (AKS) and a lightweight edge Kubernetes environment (K3s).

-----------------

Q3 Environment Setup (Cloud vs Edge) & Deployment of VNF(s)
10 Points
Grading comment:
How did you set up the cloud and edge Kubernetes environments, deploy the same VNF(s) in both, and what configuration details, challenges and "hello world" results can you report? 2500 characters with spaces max.
-----------------
# AKS Setup
Initially, an AKS cluster developed for a previous lab was repurposed. However, a number of quota issues were encountered because two virtual machines from earlier labs were still running alongside the AKS cluster. To resolve this, one of the VMs was removed and the AKS environment was rebuilt with a clean configuration.
The main cluster setup commands are contained in:
1. setupAKSCluster.sh
Helm was used to deploy the Open5GS Helm chart. Helm was selected because it works consistently across both AKS and K3s clusters and allows configuration to be easily modified through YAML values files.
Initially, the Open5GS deployment was reduced in size to fit within the minimal cluster configuration required for the lab environment. As AKS represented the cloud deployment, the cluster was later expanded to include additional nodes.
The node scaling and configuration commands are contained in:
2. setupAKSNode.sh
A key challenge during this stage was the resource quota limitations of the Azure student subscription, which restricted available CPU and VM sizes. However, this also provided useful experience with Azure resource monitoring tools. In particular, the Cost Analysis view in the Azure portal helped monitor and understand the cost and allocation of resources.
To simplify repeated experimentation, an aks.sh script was created to automate starting and stopping the AKS cluster (and keep costs down).
As a simple “hello world” validation, a Nginx deployment was installed on the cluster and tested using curl to confirm the nodes were reachable and networking was functioning correctly. The Open5GS WebUI was also successfully accessed to verify that the deployment had completed correctly.

# K3s Setup
K3s was selected as the edge Kubernetes environment because it is designed to be lightweight and suitable for resource-constrained environments.
The K3s installation and configuration commands are contained in:
3. setupK3sNode.sh
The main challenge in the K3s setup was reducing the Open5GS deployment so that it could run efficiently on the smaller edge node. This required adjusting CPU and memory allocations in the Helm values configuration.
The same Open5GS Helm chart used in AKS was deployed in the K3s cluster, ensuring that both environments used the same VNF implementation and deployment method.
As with the AKS deployment, the Open5GS WebUI was used as a simple “hello world” validation to confirm that the services were running correctly. In addition, monitoring of pod health and node resource usage was used to verify that the cluster was operating correctly once resource allocations were tuned.

-----------------

Q4 Experimental Design and Performance Monitoring
10 Points
Grading comment:
Describe the setup of your experiment design and the performance metrics that were measured, including how they were obtained. 2500 characters with spaces max.
---------



----------

Q5 Results and Discussion
10 Points
Grading comment:
Results - in the form of tables and /or graphs. To be uploaded. Discussion of results and contrast with the literature. 3000 characters with spaces max.

Q6 Developed code, scripts, and GenAI troubleshooting
10 Points
Grading comment:
You can either: 1) provide a link to Git, or 2) create a Zip or tar archive of the files which make up your system and upload it here.


Q7 Demo. Video
0 Points
Grading comment:
Short video (maximum 2 minutes long) to demonstrate your solution and results. You can either: 1) upload it here, or 2) upload on any cloud platform of your choice, e.g. YouTube and provide the link.