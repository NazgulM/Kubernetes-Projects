# Kubernetes upgrade 

```
# both 

kubectl get node
sudo apt-mark unhold kubeadm && \
sudo apt-get update && sudo apt-get install -y kubeadm=1.26.4-00 && \
sudo apt-mark hold kubeadm

# Commands only on master nodes
kubeadm version
kubeadm version: &version.Info{Major:"1", Minor:"26", GitVersion:"v1.26.4", GitCommit:"f89670c3aa4059d6999cb42e23ccb4f0b9a03979", GitTreeState:"clean", BuildDate:"2023-04-12T12:12:17Z", GoVersion:"go1.19.8", Compiler:"gc", Platform:"linux/amd64"}

kubeadm upgrade plan
# You can now apply the upgrade by executing the following command:
kubeadm upgrade apply v1.26.4

kubeadm upgrade apply -y v1.26.4

MASTER=`kubectl get nodes -ojsonpath="{.items[0].metadata.name}"`
echo $MASTER
ubuntu-master

WORKER=`kubectl get nodes -ojsonpath="{.items[1].metadata.name}"`
echo $WORKER
ubuntu-master

kubectl drain $MASTER --ignore-daemonsets
kubectl drain $WORKER --ignore-daemonsets

# worker
sudo kubeadm upgrade node

# BOTH 
apt-mark unhold kubelet kubectl && \
apt-get update && sudo apt-get install -y kubelet=$VERSION kubectl=$VERSION && \
apt-mark hold kubelet kubectl

# After updating restart the kubelet
systemctl daemon-reload
systemctl restart kubelet

kubectl uncordon $MASTER
kubectl uncordon $WORKER

kubectl get nodes
NAME            STATUS   ROLES           AGE    VERSION
ubuntu-master   Ready    control-plane   3h1m   v1.26.4
ubuntu-worker   Ready    <none>          171m   v1.26.4
```

