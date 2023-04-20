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

kubectl create sa cicd-token -n app-team1 

kubectl create rolebinding deployment-clusterrole --clusterrole=deployment-clusterrole --serviceaccount=default:cicd-token -n app-team1
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
