What is Helm in Kubernetes?

Helm is a package manager for Kubernetes.
It helps you install, configure, upgrade, and manage complex Kubernetes applications using reusable templates called charts.

A simple analogy:

Ecosystem	Package Manager
Ubuntu	apt
Python	pip
Node.js	npm
Kubernetes	Helm

So instead of manually writing dozens of Kubernetes YAML files, Helm allows you to deploy an application with one command.

SCTP

5G NGAP (gNB↔AMF) uses SCTP. Kubernetes supports SCTP for ClusterIP/NodePort, but LoadBalancer SCTP depends on the cloud provider and often isn’t supported.
So the simplest AKS lab setup is: run the gNB/UE simulator inside AKS (no need to expose SCTP publicly).
https://learn.microsoft.com/en-us/answers/questions/573521/does-azure-aks-support-sctp-and-how-to-enable-it

