# Installing  Kubernetes on Ubuntu 22 VM

1; Create the VM machine

```
swapoff -a
```

Swapoff disables swapping on the specified devices and files. When the -a flag is given, swapping is disabled on all known swap devices and files (as found in /proc/swaps or /etc/fstab).

```
apt-get update
apt install containerd -y
mkdir -p /etc/containerd 
containerd config default | sudo tee /etc/containerd/config.toml
vi /etc/containerd/config.toml
# Change Systemgroupd= true

systemctl restart containerd
curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
# Download the Google Cloud public signing key

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
# Add the Kubernetes apt repository:

# Update apt package index with the new repository and install kubectl
apt-get update
apt-cache policy kubelet | head -n 20
# Shown different versions available to install

VERSION=1.27.0-00
# Create variable of kubelet version

apt-get install -y kubelet=$VERSION kubeadm=$VERSION kubectl=$VERSION
apt-mark hold kubelet kubectl kubeadm containerd
kubelet set on hold.
kubectl set on hold.
kubeadm set on hold.
containerd set on hold.

# mark 4 packages on hold for prevent those packages updated when someone coe along and updates the system from updating. 

systemctl status kubelet.service
systemctl status containerd.service

systemctl enable kubelet.service
systemctl enable containerd.service
```

2; Bootstrapping a Cluster with kubeadm

```
wget https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
kubeadm config print init-defaults | tee ClusterConfiguration.yaml

sed -i 's/ advertiseAddress: 1.2.3.4/ advertiseAddress: 157.230.229.52/' ClusterConfiguration.yaml 

# Set the cgroupDriver to systemd 
cat <<EOF  | cat >> ClusterConfiguration.yaml 
> ---
> apiVersion: kubelet.config.k8s.io/v1beta1
> kind: KubeletConfiguration
> cgroupDriver: systemd
> EOF
```

Method 2 for installing Kubernetes:

```
Create 2 VM ubuntu, one for master node one for worker node
cat <<EOF | tee /etc/modules-load.d/containerd.conf
> overlay
> br_netfilter
> EOF
# Create the configuration file for containerd and add 2 modules

# Load modules
modprobe overlay
modprobe br_netfilter

# Create system configuration for Kubernetes networking
cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply those settings
sysctl --system

# Install containerd
sudo apt-get update && sudo apt-get install -y containerd

# Create default configuration file for containerd
# Create folder and generate default  config files and sav

sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
# restart containerd
sudo systemctl restart containerd
# Verify that is running
sudo systemctl status containerd

# Disable swap
swapoff -a

sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Install dependencies and packages
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-get update && sudo apt-get install -y apt-transport-https curl

# Add Kubernetes to the repository list
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

VERSION=1.25.0-00
apt-get install -y kubelet=$VERSION kubeadm=$VERSION kubectl=$VERSION 

# Make sure that they don'g get update automatically 
apt-mark hold kubelet kubeadm kubectl
```

Next steps only for the master node:

```
kubeadm init --pod-network-cidr 192.168.0.0/16 --kubernetes-version 1.25.0
# Pulling all the images and doing all the setup

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
kubectl get nodes --watch
NAME            STATUS   ROLES           AGE     VERSION
ubuntu-master   Ready    control-plane   7m44s   v1.25.0

kubeadm token create --print-join-command
# We can enter to the worker node

# Copy the following command for the worker node and run it
kubeadm join 157.245.246.247:6443 --token 5dm2gr.jyix7e11t0u0o2a3 --discovery-token-ca-cert-hash sha256:2241597691a3756a27ecdd9fb6b6e430a6da35d5f4431a2b4f86ae637f274d24 

kubectl get nodes
NAME            STATUS   ROLES           AGE    VERSION
ubuntu-master   Ready    control-plane   11m    v1.25.0
ubuntu-worker   Ready    <none>          105s   v1.25.0
```
