# Setup a basic Kubernetes cluster with ease using RKE

1; Create 4 droplets Ubuntu 22.10.
```
wget https://github.com/rancher/rke/releases/download/v1.4.4/rke_linux-amd64

mv rke_linux-amd64 rke
# For execute rke commands move to the /usr/local/bin
mv rke /usr/local/bin/

rke version
INFO[0000] Running RKE version: v1.4.4  

# Install kubectl binary with curl on Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

kubectl version --short
Flag --short has been deprecated, and will be removed in the future. The --short output will become the default.
Client Version: v1.27.1
Kustomize Version: v5.0.1

3 Ubuntu 16.04 nodes with 2(v)CPUs, 4GB of memory and with swap disabled
Make sure swap is disabled by running swapoff -a and removing any swap entry in /etc/fstab. You must be able to access the node using SSH. As this is a multi-node cluster, the required ports need to be opened before proceeding.
swapoff -a
apt install firewalld -y
firewall-cmd --zone=public --add-port=6443/tcp --permanent
firewall-cmd --reload
success
success

Docker installed on each Linux node
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg

# Add Docker’s official GPG key:
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

Repeat all step fr all 4 machines

# Update the apt package index
sudo apt-get update -y




rke config
[+] Cluster Level SSH Private Key Path [~/.ssh/id_rsa]: 
[+] Number of Hosts [1]: 3
[+] SSH Address of host (1) [none]: 67.205.129.190
[+] SSH Port of host (1) [22]: 
[+] SSH Private Key Path of host (67.205.129.190) [none]: 
[-] You have entered empty SSH key path, trying fetch from SSH key parameter
[+] SSH Private Key of host (67.205.129.190) [none]: 
[-] You have entered empty SSH key, defaulting to cluster level SSH key: ~/.ssh/id_rsa
[+] SSH User of host (67.205.129.190) [ubuntu]: rke
[+] Is host (67.205.129.190) a Control Plane host (y/n)? [y]: y
[+] Is host (67.205.129.190) a Worker host (y/n)? [n]: n
[+] Is host (67.205.129.190) an etcd host (y/n)? [n]: y
[+] Override Hostname of host (67.205.129.190) [none]: 
[+] Internal IP of host (67.205.129.190) [none]: 
[+] Docker socket path on host (67.205.129.190) [/var/run/docker.sock]: 
[+] SSH Address of host (2) [none]: 134.122.19.29
[+] SSH Port of host (2) [22]: 
[+] SSH Private Key Path of host (134.122.19.29) [none]: 
[-] You have entered empty SSH key path, trying fetch from SSH key parameter
[+] SSH Private Key of host (134.122.19.29) [none]: 
[-] You have entered empty SSH key, defaulting to cluster level SSH key: ~/.ssh/id_rsa
[+] SSH User of host (134.122.19.29) [ubuntu]: rke
[+] Is host (134.122.19.29) a Control Plane host (y/n)? [y]: n
[+] Is host (134.122.19.29) a Worker host (y/n)? [n]: y
[+] Is host (134.122.19.29) an etcd host (y/n)? [n]: n
[+] Override Hostname of host (134.122.19.29) [none]: 
[+] Internal IP of host (134.122.19.29) [none]: 
[+] Docker socket path on host (134.122.19.29) [/var/run/docker.sock]: 
[+] SSH Address of host (3) [none]: 157.245.83.107
[+] SSH Port of host (3) [22]: 
[+] SSH Private Key Path of host (157.245.83.107) [none]: 
[-] You have entered empty SSH key path, trying fetch from SSH key parameter
[+] SSH Private Key of host (157.245.83.107) [none]: 
[-] You have entered empty SSH key, defaulting to cluster level SSH key: ~/.ssh/id_rsa
[+] SSH User of host (157.245.83.107) [ubuntu]: rke
[+] Is host (157.245.83.107) a Control Plane host (y/n)? [y]: n
[+] Is host (157.245.83.107) a Worker host (y/n)? [n]: y
[+] Is host (157.245.83.107) an etcd host (y/n)? [n]: n
[+] Override Hostname of host (157.245.83.107) [none]: 
[+] Internal IP of host (157.245.83.107) [none]: 
[+] Docker socket path on host (157.245.83.107) [/var/run/docker.sock]: 
Network Plugin Type (flannel, calico, weave, canal, aci) [canal]: flannel
[+] Authentication Strategy [x509]: 
[+] Authorization Mode (rbac, none) [rbac]: 
[+] Kubernetes Docker image [rancher/hyperkube:v1.25.6-rancher4]: 
[+] Cluster domain [cluster.local]: 
[+] Service Cluster IP Range [10.43.0.0/16]: 
[+] Enable PodSecurityPolicy [n]: 
[+] Cluster Network CIDR [10.42.0.0/16]: 
[+] Cluster DNS Service IP [10.43.0.10]: 
[+] Add addon manifest URLs or YAML files [no]: 

kubectl get nodes
```

