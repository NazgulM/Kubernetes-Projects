# Control ServiceAccount permissions using RBAC

There are existing Namespaces ns1 and ns2 .
Create ServiceAccount pipeline in both Namespaces.

These SAs should be allowed to view almost everything in the whole cluster. You can use the default ClusterRole view for this.
These SAs should be allowed to create and delete Deployments in their Namespace.
Verify everything using kubectl auth can-i .

```
k get ns
NAME                 STATUS   AGE
default              Active   6d8h
kube-node-lease      Active   6d8h
kube-public          Active   6d8h
kube-system          Active   6d8h
local-path-storage   Active   6d8h
ns1                  Active   12s
ns2                  Active   12s

k create sa pipeline -n ns1
serviceaccount/pipeline created

k create sa pipeline -n ns2
serviceaccount/pipeline created

k create clusterrolebinding pipeline-view --clusterrole view --serviceaccount ns1:pipeline --serviceaccount ns2:pipeline
clusterrolebinding.rbac.authorization.k8s.io/pipeline-view created

Manage Deployments in certain Namespaces
k create clusterrole pipeline-deployment --verb create,delete --resource deployments
clusterrole.rbac.authorization.k8s.io/pipeline-deployment created

k -n ns1 create rolebinding pipeline-deployment --clusterrole pipeline-deployment --serviceaccount ns1:pipeline
rolebinding.rbac.authorization.k8s.io/pipeline-deployment created

k -n ns2 create rolebinding pipeline-deployment --clusterrole pipeline-deployment --serviceaccount ns2:pipeline
rolebinding.rbac.authorization.k8s.io/pipeline-deployment created

Verify
k auth can-i delete deployments --as system:serviceaccount:ns1:pipeline -n ns1
yes

k auth can-i create deployments --as system:serviceaccount:ns1:pipeline -n ns1
yes

k auth can-i update deployments --as system:serviceaccount:ns1:pipeline -n ns1
no

controlplane $ k auth can-i list deployments --as system:serviceaccount:ns1:pipeline -n ns1
yes
controlplane $ k auth can-i get deployments --as system:serviceaccount:ns1:pipeline -n ns1
yes

k auth can-i get deployments --as system:serviceaccount:ns2:pipeline -n ns2
yes
```

