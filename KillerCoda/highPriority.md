# Priority Scheduling
In Namespace lion there is one existing Pod which requests 1Gi of memory resources.
That Pod has a specific priority because of its PriorityClass.
Create new Pod named important of image nginx:1.21.6-alpine in the same Namespace. It should request 1Gi memory resources.

Assign a higher priority to the new Pod so it's scheduled instead of the existing one.

Both Pods won't fit in the cluster.
Check for existing PriorityClasses, and the the one of the existing Pod
```
k -n lion get pod
k -n lion get pod -oyaml | grep priority
k get priorityClass

k -n lion run important --image=nginx:1.21.6-alpine -oyaml --dry-run=client > pod.yaml

apiVersion: v1
kind: Pod
metadata:
  labels:
    run: important
  name: important
  namespace: lion
spec:
  priorityClassName: level3
  containers:
  - image: nginx:1.21.6-alpine
    name: important
    resources:
      requests:
        memory: 1Gi
  dnsPolicy: ClusterFirst
  restartPolicy: Always

k -n lion get pod
```


