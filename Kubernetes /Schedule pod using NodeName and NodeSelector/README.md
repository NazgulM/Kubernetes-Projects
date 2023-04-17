# Scheduling pod under the node name

First, we have to check the nodes on our machine

```
k get node
NAME           STATUS   ROLES           AGE    VERSION
controlplane   Ready    control-plane   6d4h   v1.26.1
node01         Ready    <none>          6d3h   v1.26.1

k describe node controlplane
# This command using for that we have to know if the controlplane node is tainted or not, because if it's tainted we cannot schedule pod on this Node.
Taints:    node-role.kubernetes.io/control-plane:NoSchedule
 
k edit node master
# Remove Taints under spec 

Or another shortcut command
 
# Shortcut command
# k patch node master -p '{"spec":{"taints":[]}}'
k patch node master -p '{"spec":{"taints":[]}}'

k patch node controlplane -p '{"spec":{"taints":[]}}'
node/controlplane patched
k describe node controlplane | grep -i taint
Taints:             <none>

# Create ns, we will create all the pods within this ns

N=pod-to-node-ns
k create ns $N

k -n $N run podnode-using-nodename --image nginx --dry-run=client -oyaml > podnode-using-nodename.yaml
 
v podnode-using-nodename.yaml edit the yaml file by adding the nodeName under the spec 
# under spec:
#  nodeName: node01

# 2nd way - Using Labels and Selectors
k get nodes --show-labels
k label nodes controlplane disk=ssd

k get nodes --show-labels
NAME           STATUS   ROLES           AGE    VERSION   LABELS
controlplane   Ready    control-plane   6d4h   v1.26.1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,disk=ssd,kubernetes.io/arch=amd64,kubernetes.io/hostname=controlplane,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=,node.kubernetes.io/exclude-from-external-load-balancers=

k run -n $N podnode-using-nodeselector --image nginx --dry-run=client -oyaml > podnode-using-nodeselector.yaml
vi podnode-using-nodeselector.yaml

```

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: podnode-using-nodeselector
  name: podnode-using-nodeselector
  namespace: pod-to-node-ns
spec:
  nodeSelector:
    disk: ssd  
  containers:

- image: nginx
    name: podnode-using-nodeselector
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}

vim podnode-using-nodeselector.yaml

# under spec

# nodeSelector

# disk: ssd

k create -f podnode-using-nodeselector.yaml

k -n $N get pods -owide
NAME                         READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
podnode-using-nodename       1/1     Running   0          25m   192.168.1.3   node01         <none>           <none>
podnode-using-nodeselector   1/1     Running   0          13m   192.168.0.8   controlplane   <none>           <none>
```
