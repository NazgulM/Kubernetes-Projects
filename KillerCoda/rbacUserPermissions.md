# Control User permissions using RBAC

There is existing Namespace applications .

User smoke should be allowed to create and delete Pods, Deployments and StatefulSets in Namespace applications.
User smoke should have view permissions (like the permissions of the default ClusterRole named view ) in all Namespaces but not in kube-system .
Verify everything using kubectl auth can-i .

```
k -n applications create role smoke --verb create,delete --resource pods,deployments,sts
role.rbac.authorization.k8s.io/smoke created

k -n applications create rolebinding smoke --role smoke --user smoke
rolebinding.rbac.authorization.k8s.io/smoke created

2;view permission in all Namespaces but not kube-system
As of now it’s not possible to create deny-RBAC in K8s
So we allow for all other Namespaces:

k get ns
NAME                 STATUS   AGE
applications         Active   15m
default              Active   6d8h
kube-node-lease      Active   6d8h
kube-public          Active   6d8h
kube-system          Active   6d8h
local-path-storage   Active   6d7h

k -n applications create rolebinding smoke-view --clusterrole view --user smoke
rolebinding.rbac.authorization.k8s.io/smoke-view created

k -n default create rolebinding smoke-view --clusterrole view --user smoke
rolebinding.rbac.authorization.k8s.io/smoke-view created

k -n kube-node-lease create rolebinding smoke-view --clusterrole view --user smoke
rolebinding.rbac.authorization.k8s.io/smoke-view created

k -n kube-public create rolebinding smoke-view --clusterrole view --user smoke
rolebinding.rbac.authorization.k8s.io/smoke-view created

k -n local-path-storage create rolebinding smoke-view --clusterrole view --user smoke
rolebinding.rbac.authorization.k8s.io/smoke-view created

# Verify 
kubectl auth can-i create deployments --as smoke -n applications
yes

kubectl auth can-i delete deployments --as smoke -n applications
yes

kubectl auth can-i create pods --as smoke -n applications
yes

kubectl auth can-i delete pods --as smoke -n applications
yes

kubectl auth can-i delete statefulsets --as smoke -n applications
yes

kubectl auth can-i delete secrets --as smoke -n applications
no

kubectl auth can-i list deployments --as smoke -n applications
yes

kubectl auth can-i list secrets --as smoke -n applications
no

kubectl auth can-i get secrets --as smoke -n applications
no

# Verify in other ns
k auth can-i list pods --as smoke -n default
yes
k auth can-i get pods --as smoke -n default
yes
k auth can-i get deployments --as smoke -n default
yes
k auth can-i get secrets --as smoke -n default
no
```
