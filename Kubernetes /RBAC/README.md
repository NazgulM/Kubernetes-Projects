# RBAC

Create a clusterrole with name "deployer-admin"
and which can only create "deployment,statefulset,daemonset"

Create Service Account "sa-token" within namespace "app-team-ns"

Create Rolebinding "sa-cluster-role-binding" which links
the Cluster Role with the Service Account

```
# Create clusterrole
k create clusterrole deployer-admin --verb=create --resource=deployment,statefulset,daemonset
kubectl get clusterrole deployer-admin 
NAME             CREATED AT
deployer-admin   2023-04-16T17:37:51Z

# Create namespace
k create ns app-team-ns
namespace/app-team-ns created

# Create serviceaccount
k create -n app-team-ns sa sa-token
serviceaccount/sa-token created

k get sa -n app-team-ns 
NAME       SECRETS   AGE
default    0         29s
sa-token   0         12s

# Create rolebinding
kubectl create rolebinding sa-cluster-role-binding --clusterrole=deployer-admin --serviceaccount=app-team-ns:sa-token
rolebinding.rbac.authorization.k8s.io/sa-cluster-role-binding created

 k describe rolebinding sa-cluster-role-binding 
Name:         sa-cluster-role-binding
Labels:       <none>
Annotations:  <none>
Role:
  Kind:  ClusterRole
  Name:  deployer-admin
Subjects:
  Kind            Name      Namespace
  ----            ----      ---------
  ServiceAccount  sa-token  app-team-ns
```
