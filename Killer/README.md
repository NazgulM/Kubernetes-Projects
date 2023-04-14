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

Task 2; Question 3:

Task weight: 1%

Use context: kubectl config use-context k8s-c1-H

There are two Pods named o3db-* in Namespace project-c13. C13 management asked you to scale the Pods down to one replica to save resources.
```
kubectl config set-context k8s-c1-H
kubectl config use-context k8s-c1-H
kubectl get pods

```
