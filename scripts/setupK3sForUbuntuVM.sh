curl -sfL https://get.k3s.io | sh -
sudo kubectl get nodes -o wide

#add permissions so don't need to run as Sudo'
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config

sudo k3s server --write-kubeconfig-mode 644

kubectl create namespace pwk-open5gs

#Install Helm
sudo apt-get install curl gpg apt-transport-https --yes
curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

#Install the OPen5gs on VM K3s implementation
helm install pwk-open5gs oci://registry-1.docker.io/gradiant/open5gs --version 2.2.0 -n pwk-open5gs

kubectl -n pwk-open5gs port-forward svc/open5gs-webui 9999:9999
kubectl -n pwk-open5gs get svc

kubectl -n pwk-open5gs get pods -o wide
kubectl -n pwk-open5gs describe pod open5gs-webui-xxxxx

helm upgrade --install open5gs oci://registry-1.docker.io/gradiantcharts/open5gs \
  -n pwk-open5gs \
  -f K3s-small.yaml
kubectl -n pwk-open5gs get pods

#Test using
http://127.0.0.1:9999