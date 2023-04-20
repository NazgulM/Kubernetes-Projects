# Deploy the given architecture diagram for implementing a Jekyll SSG.

Click on each icon (including arrows) to see more details. Once done click on the Check button to test your work.

```
k get pv
NAME          CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS    REASON   AGE
jekyll-site   1Gi        RWX            Delete           Available           local-storage            2m44s

pvc.yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jekyll-site
  namespace: development
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: local-storage
  resources:
    requests:
      storage: 1Gi

k get ns
NAME              STATUS   AGE
default           Active   88m
development       Active   6m35s
kube-node-lease   Active   88m
kube-public       Active   88m
kube-system       Active   88m

k create -f pvc.yaml 
persistentvolumeclaim/jekyll-site created

