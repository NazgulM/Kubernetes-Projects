# CKA practice tests

1. Question 1:
You have access to multiple clusters from your main terminal through kubectl contexts. Write all those context names into /opt/course/1/contexts.

```
mkdir opt/course/1
touch opt/course/1/contexts
k config get-contexts -o name  > opt/course/1/contexts
cat opt/course/1/contexts 
kubernetes-admin@kubernetes
```

Next write a command to display the current context into /opt/course/1/context_default_kubectl.sh, the command should use kubectl.

```
touch opt/course/1/context_default_kubectl.sh
echo 'kubectl config current-context' > opt/course/1/context_default_kubectl.sh
at opt/course/1/context_default_kubectl.sh
kubectl config current-context
h opt/course/1/context_default_kubectl.sh
kubernetes-admin@kubernetes
```

Finally write a second command doing the same thing into /opt/course/1/context_default_no_kubectl.sh, but without the use of kubectl.

```
touch opt/course/1/context_default_no_kubectl.sh
echo "cat ~/.kube/config | grep -i "current-context" | sed 's/current-context: //'"  > opt/course/1/context_default_no_kubectl.sh
sh opt/course/1/context_default_no_kubectl.sh
kubernetes-admin@kubernetes
```

2; Use context kubectl config use-context k8s-c1-H

Create a single Pod of image httpd:2.4.41-alpine in namespace default. The pod should named pod1 and the container name should be the pod1-container.

```
kubectl config set-context k8s-c1-H
kubectl config use-context k8s-c1-H
Switched to context "k8s-c1-H
kubectl run pod -n default pod1 --image=httpd:2.4.41-alpine --dry-run=client -o yaml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: pod1
  name: pod1
  namespace: default
spec:
  nodeName:  gke-cluster-1-default-pool-5e601002-g4h2
  containers:
  - image: httpd:2.4.41-alpine
    name: pod1-container
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

Result:

```
kubectl get pods pod1 -o wide
NAME   READY   STATUS    RESTARTS   AGE    IP           NODE                                       NOMINATED NODE   READINESS GATES
pod1   1/1     Running   0          4h9m   10.4.0.158   gke-cluster-1-default-pool-5e601002-g4h2   <none>           <none>
```

Question 3:

Task weight: 1%

Use context: kubectl config use-context k8s-c1-H

There are two Pods named o3db-* in Namespace project-c13. C13 management asked you to scale the Pods down to one replica to save resources.

```
kubectl config set-context k8s-c1-H
kubectl config use-context k8s-c1-H
kubectl get pods

```

Question 4

Task weight: 4%

Use context: kubectl config use-context k8s-c1-H

Do the following in Namespace default. Create a single Pod named ready-if-service-ready of image nginx:1.16.1-alpine. Configure a LivenessProbe which simply runs true. Also configure a ReadinessProbe which does check if the url <http://service-am-i-ready:80> is reachable, you can use wget T2 -O <http://service-am-i-ready:80> for this. Start the Pod and confirm it isn't ready because of the ReadinessProbe.

Create a second Pod named am-i-ready of image nginx:1.16.1-alpine with label id: cross-server-ready. The already existing Service service-am-i-ready should now have that second Pod as endpoint.

Now the first Pod should be in ready state, confirm that.

```
k run ready-if-service-ready --image nginx:1.16.1-alpine --dry-run=client -oyaml > pod1.yaml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: ready-if-service-ready
  name: ready-if-service-ready
spec:
  containers:
  - image: nginx:1.16.1-alpine
    name: ready-if-service-ready
    livenessProbe:
       exec:
         command:
         - 'true'
    readinessProbe:
       exec:
         command:
         - 'sh'
         - '-c'
         - 'wget -T2 -O- http://service-am-i-ready:80'
  
   k create -f pod1.yaml 
pod/ready-if-service-ready created

k get pods 
NAME                     READY   STATUS    RESTARTS   AGE
ready-if-service-ready   0/1     Running   0          19s

k describe pod ready-if-service-ready
Events:
  Type     Reason     Age               From               Message
  ----     ------     ----              ----               -------
  Normal   Scheduled  26s               default-scheduler  Successfully assigned default/ready-if-service-ready to node01
  Normal   Pulled     26s               kubelet            Container image "nginx:1.16.1-alpine" already present on machine
  Normal   Created    26s               kubelet            Created container ready-if-service-ready
  Normal   Started    26s               kubelet            Started container ready-if-service-ready
  Warning  Unhealthy  6s (x5 over 25s)  kubelet            Readiness probe failed: wget: bad address 'service-am-i-ready:80'
```

5; Use kubectl config use-context k8s-c1-H
There are various pod in all namespaces. Write a command into /opt/course/5/fin_pods.sh which lists all pods sorted by their age
 (metadata.creationTimestamp)

 ```
 k get pods -A --sort-by=metadata.creationTimestamp
NAMESPACE            NAME                                       READY   STATUS    RESTARTS   AGE
kube-system          kube-proxy-pftdf                           1/1     Running   0          7d15h
kube-system          calico-kube-controllers-5f94594857-smxtv   1/1     Running   3          7d15h
kube-system          kube-scheduler-controlplane                1/1     Running   2          7d15h
kube-system          kube-controller-manager-controlplane       1/1     Running   2          7d15h
kube-system          etcd-controlplane                          1/1     Running   0          7d15h
kube-system          kube-apiserver-controlplane                1/1     Running   2          7d15h
local-path-storage   local-path-provisioner-8bc8875b-9wjmj      1/1     Running   0          7d15h
kube-system          kube-proxy-ldwqn                           1/1     Running   0          7d15h
kube-system          coredns-68dc769db8-9h8gn                   1/1     Running   0          7d15h
kube-system          coredns-68dc769db8-6cwk7                   1/1     Running   0          7d15h
kube-system          canal-vpgtp                                2/2     Running   0          79m
kube-system          canal-d2m2v                                2/2     Running   0          79m
ns1                  pod1                                       1/1     Running   0          110s
default              pod2                                       1/1     Running   0          102s
default              pod3                                       1/1     Running   0          6s

echo "kubectl get pods -A --sort-by=metadata.creationTimestamp" > opt/course/5/find-pods.sh 

cat opt/course/5/find-pods.sh 
kubectl get pods -A --sort-by=metadata.creationTimestamp

sh opt/course/5/find-pods.sh 
NAMESPACE            NAME                                       READY   STATUS    RESTARTS   AGE
kube-system          kube-proxy-pftdf                           1/1     Running   0          7d15h
kube-system          calico-kube-controllers-5f94594857-smxtv   1/1     Running   3          7d15h
kube-system          kube-scheduler-controlplane                1/1     Running   2          7d15h
kube-system          kube-controller-manager-controlplane       1/1     Running   2          7d15h
kube-system          etcd-controlplane                          1/1     Running   0          7d15h
kube-system          kube-apiserver-controlplane                1/1     Running   2          7d15h
local-path-storage   local-path-provisioner-8bc8875b-9wjmj      1/1     Running   0          7d15h
kube-system          kube-proxy-ldwqn                           1/1     Running   0          7d15h
kube-system          coredns-68dc769db8-9h8gn                   1/1     Running   0          7d15h
kube-system          coredns-68dc769db8-6cwk7                   1/1     Running   0          7d15h
kube-system          canal-vpgtp                                2/2     Running   0          83m
kube-system          canal-d2m2v                                2/2     Running   0          83m
ns1                  pod1                                       1/1     Running   0          6m15s
default              pod2                                       1/1     Running   0          6m7s
default              pod3                                       1/1     Running   0          4m31s
```

Write second command into opt/course/5/fin-pods-uid.sh which list all pods sorted by field metadata.uid. Use Use kubectl sorting for both commands

```
k get pods -A --sort-by=metadata.uid
NAMESPACE            NAME                                       READY   STATUS    RESTARTS   AGE
kube-system          kube-scheduler-controlplane                1/1     Running   2          7d15h
kube-system          kube-controller-manager-controlplane       1/1     Running   2          7d15h
kube-system          coredns-68dc769db8-9h8gn                   1/1     Running   0          7d15h
local-path-storage   local-path-provisioner-8bc8875b-9wjmj      1/1     Running   0          7d15h
kube-system          coredns-68dc769db8-6cwk7                   1/1     Running   0          7d15h
kube-system          kube-apiserver-controlplane                1/1     Running   2          7d15h
kube-system          canal-vpgtp                                2/2     Running   0          84m
default              pod2                                       1/1     Running   0          7m18s
kube-system          etcd-controlplane                          1/1     Running   0          7d15h
kube-system          kube-proxy-pftdf                           1/1     Running   0          7d15h
kube-system          calico-kube-controllers-5f94594857-smxtv   1/1     Running   3          7d15h
default              pod3                                       1/1     Running   0          5m42s
kube-system          canal-d2m2v                                2/2     Running   0          84m
ns1                  pod1                                       1/1     Running   0          7m26s
kube-system          kube-proxy-ldwqn                           1/1     Running   0          7d15h

controlplane $ echo "kubectl get pods -A --sort-by=metadata.uid" > opt/course/5/find-pods-uid.sh 
controlplane $ sh opt/course/5/find-pods-uid.sh 
NAMESPACE            NAME                                       READY   STATUS    RESTARTS   AGE
kube-system          kube-scheduler-controlplane                1/1     Running   2          7d15h
kube-system          kube-controller-manager-controlplane       1/1     Running   2          7d15h
kube-system          coredns-68dc769db8-9h8gn                   1/1     Running   0          7d15h
local-path-storage   local-path-provisioner-8bc8875b-9wjmj      1/1     Running   0          7d15h
kube-system          coredns-68dc769db8-6cwk7                   1/1     Running   0          7d15h
kube-system          kube-apiserver-controlplane                1/1     Running   2          7d15h
kube-system          canal-vpgtp                                2/2     Running   0          89m
default              pod2                                       1/1     Running   0          12m
kube-system          etcd-controlplane                          1/1     Running   0          7d15h
kube-system          kube-proxy-pftdf                           1/1     Running   0          7d15h
kube-system          calico-kube-controllers-5f94594857-smxtv   1/1     Running   3          7d15h
default              pod3                                       1/1     Running   0          10m
kube-system          canal-d2m2v                                2/2     Running   0          89m
ns1                  pod1                                       1/1     Running   0          12m
kube-system          kube-proxy-ldwqn                           1/1     Running   0          7d15h
```

6; Show nodes resource usage
   Show Pods and their containers resource usage

```
kubectl top nodes
echo "kubectl top node" > /opt/course/7/node.sh
sh /opt/course/7/node.sh

kubectl top pods --containers
echo "kubectl top pods --containers" > /opt/course/7/pods.sh
```

7; ssh into the master ssh controlplane. Check the master components kubelet, kube-apiserver, kube-scheduler, kube-controller-manager and etcd are started, installed on the master node. Also find out the name of the DNS app and how it's started/installed in the master node.

Write your findings into /opt/course/8/master-components.txt

```
mkdir -p opt/course/8
touch opt/course/8/master-components.txt
vi opt/course/8/master-components.txt

kubelet: [TYPE]
kube-apiserver: [TYPE]
kube-scheduler: [TYPE]
kube-controller-manager: [TYPE]
etcd: [TYPE]
dns: [TYPE] [NAME]

Choices of [TYPE are: noy-installed, process, static-pod, pod
]

ssh controlplane
k get all -n kube-system | grep -i dns
# Search each system one by one
pod/coredns-68dc769db8-6cwk7                   1/1     Running   0             8d
pod/coredns-68dc769db8-9h8gn                   1/1     Running   0             8d
service/kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   8d
deployment.apps/coredns                   2/2     2            2           8d
replicaset.apps/coredns-68dc769db8                   2         2         2       8d
replicaset.apps/coredns-787d4945fb                   0         0         0       8d

have to edit the file

kubelet: [TYPE]
kube-apiserver: [TYPE]
kube-scheduler: [TYPE]
kube-controller-manager: [TYPE]
etcd: [TYPE]
dns: pod coredns

ls /etc/kubernetes/manifests 
etcd.yaml  
kube-apiserver.yaml  
kube-controller-manager.yaml  
kube-scheduler.yaml

All of these system are static-pods
k get all -n kube-system | grep -i etcd
pod/etcd-controlplane

kubelet: [TYPE]
kube-apiserver: [TYPE]
kube-scheduler: [TYPE]
kube-controller-manager: [TYPE]
etcd: static-pod
dns: pod coredns

k get all -n kube-system | grep -i kube-controller-manager

kubelet: [TYPE]
kube-apiserver: static-pod
kube-scheduler: static-pod
kube-controller-manager: static-pod
etcd: static-pod
dns: pod coredns

ps aux | grep -i kubelet
root       24238  2.5  3.3 1434564 67724 ?       Ssl  17:44   2:19 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock --pod-infra-container-image=registry.k8s.io/pause:3.9 --container-runtime remote --container-runtime-endpoint unix:///run/containerd/containerd.sock --cgroup-driver=systemd --eviction-hard imagefs.available<5%,memory.available<100Mi,nodefs.available<5%
root       33785  5.2 15.7 1119152 319276 ?      Ssl  17:50   4:32 kube-apiserver --advertise-address=172.30.1.2 --allow-privileged=true --authorization-mode=Node,RBAC --client-ca-file=/etc/kubernetes/pki/ca.crt --enable-admission-plugins=NodeRestriction --enable-bootstrap-token-auth=true --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key --etcd-servers=https://127.0.0.1:2379 --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key --requestheader-allowed-names=front-proxy-client --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt --requestheader-extra-headers-prefix=X-Remote-Extra- --requestheader-group-headers=X-Remote-Group --requestheader-username-headers=X-Remote-User --secure-port=6443 --service-account-issuer=https://kubernetes.default.svc.cluster.local --service-account-key-file=/etc/kubernetes/pki/sa.pub --service-account-signing-key-file=/etc/kubernetes/pki/sa.key --service-cluster-ip-range=10.96.0.0/12 --tls-cert-file=/etc/kubernetes/pki/apiserver.crt --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
root       81516  0.0  0.0   3436   724 pts/2    S+   19:16   0:00 grep --color=auto -i kubelet

k get all -n kube-system
NAME                                           READY   STATUS    RESTARTS      AGE
pod/calico-kube-controllers-5f94594857-smxtv   1/1     Running   3             8d
pod/canal-cctlc                                2/2     Running   0             87m
pod/canal-qjk9k                                2/2     Running   0             87m
pod/coredns-68dc769db8-6cwk7                   1/1     Running   0             8d
pod/coredns-68dc769db8-9h8gn                   1/1     Running   0             8d
pod/etcd-controlplane                          1/1     Running   0             8d
pod/kube-apiserver-controlplane                1/1     Running   2             8d
pod/kube-controller-manager-controlplane       1/1     Running   2             8d
pod/kube-proxy-ldwqn                           1/1     Running   0             8d
pod/kube-proxy-pftdf                           1/1     Running   0             8d
pod/kube-scheduler-controlplane                1/1     Running   2 (88m ago)   8d

NAME               TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
service/kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   8d

NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/canal        2         2         2       2            2           kubernetes.io/os=linux   8d
daemonset.apps/kube-proxy   2         2         2       2            2           kubernetes.io/os=linux   8d

NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/calico-kube-controllers   1/1     1            1           8d
deployment.apps/coredns                   2/2     2            2           8d

NAME                                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/calico-kube-controllers-5f94594857   1         1         1       8d
replicaset.apps/coredns-68dc769db8                   2         2         2       8d
replicaset.apps/coredns-787d4945fb                   0         0         0       8d

kubelet: process
kube-apiserver: static-pod
kube-scheduler: static-pod
kube-controller-manager: static-pod
etcd: static-pod
dns: pod coredns
```

7; Ssh into master node, temporarily stop the kube-scheduler, this means in a way that you can start again afterwards.

Create a single Pod named manual-schedule of image httpd:2.4-alpine, confirm its created but not scheduled in any node.

Now you are the scheduler and have all its power, manually schedule that Pod on node, make sure its running.

Start the kube-scheduler again and confirm its running correctly by creating a second pod named manual-schedule2 of image httpd:2.4-alpine and check if its running on worker

```
ssh controlplane 
Last login: Wed Apr 19 19:03:31 2023 from 127.0.0.1

k get all -n kube-system | grep -i kube-scheduler
pod/kube-scheduler-controlplane                1/1     Running   2 (93m ago)   8d

cd /etc/kubernetes/manifests/
ls -lrt
total 16
-rw------- 1 root root 3998 Apr 11 13:48 kube-apiserver.yaml
-rw------- 1 root root 3520 Apr 11 13:48 kube-controller-manager.yaml
-rw------- 1 root root 2369 Apr 11 13:48 etcd.yaml
-rw------- 1 root root 1439 Apr 11 13:48 kube-scheduler.yaml

mv ./kube-scheduler.yaml  ../
ls -lrt
total 12
-rw------- 1 root root 3998 Apr 11 13:48 kube-apiserver.yaml
-rw------- 1 root root 3520 Apr 11 13:48 kube-controller-manager.yaml
-rw------- 1 root root 2369 Apr 11 13:48 etcd.yaml

ls -lrt ../
total 40
drwxr-xr-x 3 root root 4096 Apr 11 13:46 pki
-rw------- 1 root root 1982 Apr 11 13:47 kubelet.conf
-rw------- 1 root root 1439 Apr 11 13:48 kube-scheduler.yaml
-rw------- 1 root root 5638 Apr 19 17:50 admin.conf
-rw------- 1 root root 5666 Apr 19 17:50 controller-manager.conf
-rw------- 1 root root 5618 Apr 19 17:50 scheduler.conf
drwxr-xr-x 2 root root 4096 Apr 19 19:25 manifests

k get pods -n kube-system | grep -i kube-scheduler
k get all -n kube-system | grep -i kube-scheduler
# It is empty now

k run manual-schedule --image httpd:2.4-alpine
pod/manual-schedule created

k get pod manual-schedule 
NAME              READY   STATUS    RESTARTS   AGE
manual-schedule   0/1     Pending   0          10s
# Now without kube-scheduler status indicate as Pending, it doesn't know what to choose and status is Pending.

mv ../kube-scheduler.yaml ./
ls
etcd.yaml  kube-apiserver.yaml  kube-controller-manager.yaml  kube-scheduler.yaml

k get pods -n kube-system | grep -i kube-scheduler
kube-scheduler-controlplane                1/1     Running   0          49s

k get pods manual-schedule  
NAME              READY   STATUS    RESTARTS   AGE
manual-schedule   1/1     Running   0          4m4s

k run manual-schedule2 --image httpd:2.4-alpine --dry-run=client -oyaml > 1.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: manual-schedule2
  name: manual-schedule2
spec:
  nodeName: node01
  containers:
  - image: httpd:2.4-alpine
    name: manual-schedule2
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}

k get pods manual-schedule2
Error from server (NotFound): pods "manual-schedule2" not found

 k create -f 1.yaml 
pod/manual-schedule2 created

 k get pods manual-schedule2 -o wide --watch
NAME               READY   STATUS    RESTARTS   AGE   IP            NODE     NOMINATED NODE   READINESS GATES
manual-schedule2   1/1     Running   0          13s   192.168.1.4   node01  
```

8; Create a new ServiceAccount processor in Namespace project-hamster. Create a Role and RoleBinding , both named processor as well. These should allow the new SA to only create Secrets and ConfigMaps in that Namespace

```
k create ns project-hamster
namespace/project-hamster created

k get sa -n project-hamster
NAME      SECRETS   AGE
default   0         18s

k create sa processor -n project-hamster 
serviceaccount/processor created

k api-resources | grep -i secret
secrets

k create role processor -n project-hamster --verb=create --resource=secrets,configmaps
role.rbac.authorization.k8s.io/processor created

k get role -n project-hamster 
NAME        CREATED AT
processor   2023-04-19T20:29:15Z

k describe role processor -n project-hamster 
Name:         processor
Labels:       <none>
Annotations:  <none>
PolicyRule:
  Resources   Non-Resource URLs  Resource Names  Verbs
  ---------   -----------------  --------------  -----
  configmaps  []                 []              [create]
  secrets     []                 []              [create]

rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  creationTimestamp: null
  name: processor
  namespace: project-hamster
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: processor
subjects:
- kind: ServiceAccount
  name: processor
  namespace: project-hamster

k create rolebinding processor -n project-hamster --serviceaccount=project-hamster:processor --role=processor                        
rolebinding.rbac.authorization.k8s.io/processor created

k get rolebinding -n project-hamster 
NAME        ROLE             AGE
processor   Role/processor   8s

# Verify
 k auth can-i create secret --as=system:serviceaccount:project-hamster:processor --namespace project-hamster
yes

k auth can-i create configmap --as=system:serviceaccount:project-hamster:processor --namespace default        
no
```

9; Use namespace project-tiger. Create a DaemonSet named ds-important with image httpd:2.4.-alpine and labels id-ds-important and uuid==184226. The Pods it creates should request 10 millicore cpu and 10 mebibyte memory. The Pods of that DaemonSet should run on all nodes, master and worker

```
k create ns project-tiger
namespace/project-tiger created

ds.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ds-important
  namespace: project-tiger
  labels:
    id: ds-important
    uuid: 18426aabbcc
spec:
  selector:
    matchLabels:
      id: ds-important
      uuid: 18426aabbcc
  template:
    metadata:
      labels:
        id: ds-important
        uuid: 18426aabbcc
    spec:
      tolerations:
      # these tolerations are to have the daemonset runnable on control plane nodes
      # remove them if your control plane nodes should not run pods
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
        effect: NoSchedule
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      containers:
      - name: ds-important
        image: httpd:2.4-alpine
        resources:
          requests:
            cpu: 10m
            memory: 10Mi
  
k create -f ds.yaml 
daemonset.apps/ds-important created

k get pods -n project-tiger -o wide
NAME                 READY   STATUS    RESTARTS   AGE    IP            NODE           NOMINATED NODE   READINESS GATES
ds-important-7t8v9   1/1     Running   0          103s   192.168.1.3   node01         <none>           <none>
ds-important-xxtch   1/1     Running   0          103s   192.168.0.8   controlplane   <none>           <none>

k get ds -n project-tiger 
NAME           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
ds-important   2         2         2       2            2           <none>          2m34s

k get nodes
NAME           STATUS   ROLES           AGE   VERSION
controlplane   Ready    control-plane   8d    v1.26.1
node01         Ready    <none>          8d    v1.26.1
```

10; Use Namespace project-tiger
Create Deployment named deploy-important with label id=very-important (the Pods should also have this label) and 3 replicas. It should contain two containers, the first named container1 with image nginx:1.17.6-alpine and the second one named container2 with image kubernetes/pause.

There should be only ever one Pod of that Deployment running on one worker node. We have two worker nodes: cluster1-worker1 and cluster1-worker2. Because the Deployment has three replicas the result should be that on both nodes one Pod is running. The third Pod won't be scheduled, unless a new worker node will be added.

In a way we kind of simulate the behaviour of a DaemonSet here, but using a Deployment and a fixed number of replicas.

```
```
11; Use context: kubectl config use-context k8s-c1-H

 

Create a Pod named multi-container-playground in Namespace default with three containers, named c1, c2 and c3. There should be a volume attached to that Pod and mounted into every container, but the volume shouldn't be persisted or shared with other Pods.

Container c1 should be of image nginx:1.17.6-alpine and have the name of the node where its Pod is running available as environment variable MY_NODE_NAME.

Container c2 should be of image busybox:1.31.1 and write the output of the date command every second in the shared volume into file date.log. You can use while true; do date >> /your/vol/path/date.log; sleep 1; done for this.

Container c3 should be of image busybox:1.31.1 and constantly send the content of file date.log from the shared volume to stdout. You can use tail -f /your/vol/path/date.log for this.

Check the logs of container c3 to confirm correct setup.

~                                                                                                                                                                   
~
