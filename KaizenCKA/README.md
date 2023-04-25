# CKA Questions from KAIZEN

1; A Kubernetes worker node, named  worker-1  is in  state NotReady. Investigate why this is the case, and perform any appropriate steps to bring the node to a Ready state, ensuring that any changes are made permanent

```
ssh worker-1
systemctl status kubelet
systemctl start kubelet 
systemctl enable kubelet
```

2; Create a new ClusterRole named  deployment-clusterrole  ,  which only allows to
 create the following resource types:
 ●  Deployment
 ●  StatefulSet
 ●  DaemonSet
 Create a new ServiceAccount named  cicd-token  in the  existing namespace app-team1. Bind the new ClusterRole deployment-clusterrole  to the new ServiceAccount  cicd-token  , limit to the namespace  app-team1

 ```
 kubectl create clusterrole deployment-clusterrole --verb=create --resource=deployments,statefulsets,daemonsets
 clusterrole.rbac.authorization.k8s.io/deployment-clusterrole created

 k create ns app-team1
namespace/app-team1 created

kubectl create sa cicd-token -n app-team1 
serviceaccount/cicd-token created

kubectl create rolebinding deployment-b --clusterrole=deployment-clusterrole -n app-team1 --serviceaccount=app-team1:cicd-token

rolebinding.rbac.authorization.k8s.io/deployment-b created

k describe rolebinding deployment-b -n app-team1
Name:         deployment-b
Labels:       <none>
Annotations:  <none>
Role:
  Kind:  ClusterRole
  Name:  deployment-clusterrole
Subjects:
  Kind            Name        Namespace
  ----            ----        ---------
  ServiceAccount  cicd-token  app-team1
```

3;   Create a new NetworkPolicy named  allow-port-from-namespace  that allows
 Pods in the existing namespace  internal  to connect to port 9000 of other Pods in the
 same namespace, Ensure that the new NetworkPolicy:
 does not allow access to Pods not listening on port 9000
 does not allow access from Pods not in namespace  internal.

 ```
 apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-port-from-namespace
  namespace: internal
spec:
  podSelector:
    matchLabels: {}
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: namespacecorp-net
    - podSelector: {}
    ports:
    - port: 9000
~                    
kubectl create -f networkPolicy3.yaml

kubectl get networkpolicy -n internal
NAME                        POD-SELECTOR   AGE
allow-port-from-namespace   <none>         45s

kubectl describe networkpolicy -n internal
Name:         allow-port-from-namespace
Namespace:    internal
Created on:   2023-04-19 22:56:59 +0000 UTC
Labels:       <none>
Annotations:  <none>
Spec:
  PodSelector:     <none> (Allowing the specific traffic to all pods in this namespace)
  Allowing ingress traffic:
    To Port: 9000/TCP
    From:
      NamespaceSelector: name=namespacecorp-net
    From:
      PodSelector: <none>
  Not affecting egress traffic
  Policy Types: Ingress
  ```

 4 . Reconfigure the existing deployment  frontend  and add a port specification named
 http exposing port 80/tcp of the existing container nginx
 Create a new service named  front-end-svc  exposing  the container port http.
 Configure the new service to also expose the individual Pods via a NodePort on the
 nodes on which they are scheduled

```
kubectl get deploy
NAME           READY   UP-TO-DATE   AVAILABLE   AGE
frontend       0/1     1            0           58m
loadbalancer   0/1     1            0           58m

kubectl expose deployment frontend --name=front-end-svc --port=80 --target-port=80 --type=NodePort
```

5; Task -
Set the node named node01 as unavailable and reschedule all the pods running on it.

```
k get pods -o wide 
NAME   READY   STATUS    RESTARTS   AGE   IP            NODE     NOMINATED NODE   READINESS GATES
pod1   1/1     Running   0          13s   192.168.1.3   node01   <none>           <none>

k drain node01 --ignore-daemonsets=false
node/node01 cordoned

k get nodes
NAME           STATUS                     ROLES           AGE   VERSION
controlplane   Ready                      control-plane   12d   v1.26.1
node01         Ready,SchedulingDisabled   <none>          12d   v1.26.1

k get pods -owide
NAME   READY   STATUS    RESTARTS   AGE    IP            NODE     NOMINATED NODE   READINESS GATES
pod1   1/1     Running   0          4m8s   192.168.1.3   node01   <none>           <none>
pod2   0/1     Pending   0          8s     <none>        <none>   <none>           <none>
```

6; Given an existing Kubernetes cluster running version 1.26.1, upgrade all of the Kubernetes control plan and node components on the master node only to version 1.26.2 You are also expected to upgrade kubelet and kubectl on the master node.

```
k get nodes
NAME           STATUS   ROLES           AGE   VERSION
controlplane   Ready    control-plane   12d   v1.26.1
node01         Ready    <none>          12d   v1.26.1

k drain controlplane --ignore-daemonsets --delete-emptydir-data
node/controlplane already cordoned
Warning: ignoring DaemonSet-managed Pods: kube-system/canal-p82vf, kube-system/kube-proxy-xkcsp
node/controlplane drained

apt-get install kubeadm=1.26.3-00 && apt-get install kubectl=1.26.3-00 && apt-get install kubelet=1.26.3-00

kubeadm upgrade apply v1.26.3 --etcd-upgrade=false
k uncordon controlplane

k get nodes
NAME           STATUS   ROLES           AGE   VERSION
controlplane   Ready    control-plane   12d   v1.26.3
node01         Ready    <none>          12d   v1.26.1
```

7; Create a snapshot of the existing etcd instance running at <https://127.0.0.1:2379> saving the snapshot to /srv/data/etcd-snapshot.db. Next, restore an existing, previous snameshot located at /var/lib/backup/etcd-snapshot-previous.db. The following TLS certificates/key are supplied for connecting to the server with etcdctl: CA certificate: /opt/KUIN00601/ca.crt Client certificate: /opt/KUIN00601/etcd-client.crt Clientkey:/opt/KUIN00601/etcd- client.key
