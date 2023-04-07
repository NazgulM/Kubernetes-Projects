# ETCD

ETCD is a distributed reliable key-value store that is simple, secure and fast.
ETCD is a database that store information in a key-value format. Key=Value
ETCD database store information regarding the cluster, cluster such as nodes, pods, configs, secrets, accounts, roles, bindings and others.
Every information, when you run the kubectl get command is from ETCD database.
ETCD starts a service that listens on port 2379 by default, very important.

## Networking

1; Create NetworkPolicy that denies all access to the payroll Pod in the accounting namespace

```
kubectl create namespace accounting
kubectl run payroll --image=nginx --namespace=accounting
kubectl get pod --namespace=accounting
NAME      READY   STATUS    RESTARTS   AGE
payroll   1/1     Running   0          13s

# Create payroll-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: payroll-policy
spec:
  podSelector:
    matchLabels:
      app: payroll
  policyTypes:
  - Ingress
  - Egress

# Run the command kubectl create -f payroll-policy.yaml
networkpolicy.networking.k8s.io/payroll-policy created
```
