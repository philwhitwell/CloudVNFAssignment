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
# Experimental Setup

The experimental design focused on comparing the performance of the User Plane Function (UPF) when deployed in two different Kubernetes environments:
* Cloud environment: Azure Kubernetes Service (AKS)
* Edge environment: K3s running on the Azure virtual machine

In both environments the same Open5GS Helm deployment was used to ensure that the VNF configuration was consistent. The goal was to observe how the different infrastructure environments affected packet forwarding performance.
To generate realistic 5G traffic flows, UERANSIM was used to emulate a 5G User Equipment (UE) and gNB.
https://github.com/aligungr/UERANSIM/wiki

UERANSIM was executed on the Azure VM and connected to the Open5GS deployment running in AKS or locally on the K3s cluster.(see 4. installForUERANSIM.sh and 5. setupOfUERANSIMToAKS.sh) 
Once the UE successfully registered with the network and established a PDU session, traffic could be generated through the UPF data plane.

## Traffic Generation

Network traffic was generated using iPerf3, which is commonly used for measuring network throughput.

The basic experiment workflow was:
* Start the iPerf3 server inside the Kubernetes environment.
* Establish a PDU session using UERANSIM.
* Run iPerf3 traffic from the UE towards the server through the UPF.
* Vary the traffic rate to observe system behaviour.

This generated UDP traffic at controlled bandwidth levels for a fixed time period.
(this was scripted using 6. upf_traffic_test.sh)

## Performance Metrics

Several performance metrics were monitored during the experiments:
* CPU utilisation of the UPF container
* Network throughput (transmit and receive)
* Memory utilisation

These metrics help identify how efficiently the UPF processes packet traffic under load.

## Monitoring and Measurement

Performance data was collected using Prometheus and Grafana, which were deployed on the monitoring node.
Prometheus collected metrics from Kubernetes nodes and containers
Example Prometheus queries included in prometheus_queries.md:
Grafana dashboards were then used to visualise the performance of the UPF during traffic tests. (The exports of the dashboards are included in the root folder)

## Test Execution

The experiments were executed in two scenarios:
1. AKS scenario – UERANSIM running on the VM and generated traffic routed to the UPF pod deployed in the AKS cluster.
2. K3s scenario – both UERANSIM and the Open5GS deployment were executed within the VM environment.

Comparing these two setups allowed the performance impact of cloud infrastructure versus lightweight edge Kubernetes to be evaluated.


----------

Q5 Results and Discussion
10 Points
Grading comment:
Results - in the form of tables and /or graphs. To be uploaded. Discussion of results and contrast with the literature. 3000 characters with spaces max.
---------
The raw experimental outputs are provided in upf_iperf3_AKS.log and upf_iperf3_K3s.log, with a summarised comparison in summaryOfUPFLogs.md. The results are also visualised in upf_throughput_comparison.png.

The key results from the iPerf3 throughput tests are summarised below:
* AKS scales almost linearly with the requested bandwidth up to 200 Mbps.
* K3s saturates around ~30–35 Mbps, suggesting CPU or networking constraints in the edge deployment.
* Jitter remains low in both environments, indicating stable packet delivery.
* Packet loss was zero in all tests, showing that throughput limitations were due to system capacity rather than network reliability.

These results show that the cloud-based AKS deployment sustained near-line-rate throughput, whereas the edge-based K3s deployment exhibited performance saturation under higher traffic loads. This highlights the impact of infrastructure resources and networking layers on UPF packet processing performance.
Additional performance metrics were captured using Grafana dashboards (UPF_capture_load onAKS.png, UPF_capture_load onK3s.png). These results provide further insight into system behaviour under load.
The Grafana monitoring results show that CPU utilisation in AKS increases significantly with traffic load, reaching approximately 40%, whereas the K3s deployment remains below 6% CPU usage. Memory usage remains relatively stable in both environments (approximately 85–95 MB), indicating that UPF performance is primarily constrained by packet processing and networking capacity rather than memory consumption.
An additional observation from the Grafana dashboards is that UPF receive traffic is approximately double the transmit traffic during high-load tests. This reflects the behaviour of the 5G user plane where GTP-U encapsulated packets are received and decapsulated by the UPF before being forwarded to external networks.
This behaviour is consistent with the 5G system architecture defined by the 3GPP specifications, which describe the UPF as performing packet routing, forwarding, and tunnelling operations between the access network and external data networks.
[Literature Reference](https://www.etsi.org/deliver/etsi_ts/123500_123599/123501/17.05.00_60/ts_123501v170500p.pdf)

The observed performance characteristics also align with findings in the literature, where UPF throughput is strongly influenced by packet processing efficiency and infrastructure networking performance. In particular, virtualisation layers and container networking can introduce overheads that affect achievable throughput, which is consistent with the lower throughput observed in the K3s edge deployment compared to the AKS cloud environment.

---------
Q6 Developed code, scripts, and GenAI troubleshooting
10 Points
Grading comment:
You can either: 1) provide a link to Git, or 2) create a Zip or tar archive of the files which make up your system and upload it here.

-------

https://youtu.be/Z4-YpnkYwLg

------
Q7 Demo. Video
0 Points
Grading comment:
Short video (maximum 2 minutes long) to demonstrate your solution and results. You can either: 1) upload it here, or 2) upload on any cloud platform of your choice, e.g. YouTube and provide the link.