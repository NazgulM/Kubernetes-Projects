# Network Policy

Create a new NetworkPolicy named "allow-port-from-namespace"

1; to allow Pods in the existing namespace "internal"
to connect on port "80" within the same namespace.

2; also only allow access from other pods in
other namespace named "corp" on port "80"

```
k create ns internal
namespace/internal created
k create ns corp
namespace/corp created
k label ns corp project=corp
namespace/corp labeled

# apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-port-from-namespace
  namespace: internal
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    # PART 1 - ALLOW PODS WITHIN SAME NAMESPACE ON PORT 80
    - podSelector: {}
 
    # PART 2 - ALLOW PODS FROM CORP NAMESPACE
    - namespaceSelector:
        matchLabels:
          project: corp

    ports:
    - protocol: TCP
      port: 80

k create -f np.yaml
# test within the namespace
k -n internal run nginxpod --image nginx --port 80
k -n internal run mongopod --image mongo --port 27017
k -n internal get pod --watch - owide

# START TESTING - PART 1
k -n internal run testpod --image busybox --rm -it -- sh

nc -v 192.168.171.80 80
nc -v 192.168.171.84 27017

# Test outside the NS
# TEST OUTSIDE THE NAMESPACE - PART 2
k -n corp run corppod --image busybox --rm -it -- sh

nc -v 192.168.171.80 80
nc -v 192.168.171.84 27017
```
