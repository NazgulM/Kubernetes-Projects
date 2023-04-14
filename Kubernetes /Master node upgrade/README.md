# Upgrade the Master Node

```
kubectl get node
k get node
NAME           STATUS   ROLES           AGE    VERSION
controlplane   Ready    control-plane   3d8h   v1.26.1
node01         Ready    <none>          3d8h   v1.26.1

apt update
apt-cache madison kubeadm
# Will show you all the available versions in repo

apt-get update && apt-get install -y --allow-change-held-packages kubeadm=1.26.3-00
The following packages will be upgraded:
  kubeadm

kubeadm version
kubeadm version: &version.Info{Major:"1", Minor:"26", GitVersion:"v1.26.3", GitCommit:"9e644106593f3f4aa98f8a84b23db5fa378900bd", GitTreeState:"clean", BuildDate:"2023-03-15T13:38:47Z", GoVersion:"go1.19.7", Compiler:"gc", Platform:"linux/amd64"}

kubeadm upgrade plan
kubeadm upgrade apply -f v1.26.3

k drain controlplane --ignore-daemonsets
apt-get update && apt-get install -y --allow-change-held-packages kubelet=1.26.3-00 kubectl=1.26.3-00

# Will upgrade those 2 components

systemctl daemon-reload
systemctl restart kubelet
k uncordon controlplane

k get node
NAME           STATUS   ROLES           AGE    VERSION
controlplane   Ready    control-plane   3d9h   v1.26.3
node01         Ready    <none>          3d8h   v1.26.1
```

