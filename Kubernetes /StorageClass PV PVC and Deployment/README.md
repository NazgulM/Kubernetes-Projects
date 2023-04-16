# Kubernetes StorageClass PV PVC and Deployment

```
1; N=pvdemo
kubectl create ns $N
# create storageClass.yaml file

---
apiVersion: storage.k8s.io/v1 
kind: StorageClass 
metadata: 
  name: localdisk
  namespace: pvdemo 
provisioner: kubernetes.io/no-provisioner 
allowVolumeExpansion: true

----
kubectl create -f storageClass.yaml
storageclass.storage.k8s.io/localdisk created

# 2; create pv.yaml file

---
apiVersion: v1 
kind: PersistentVolume 
metadata: 
  namespace: pvdemo
  name: localpv 
spec: 
  storageClassName: localdisk 
  persistentVolumeReclaimPolicy: Recycle 
  capacity: 
    storage: 1Gi 
  accessModes: 
    - ReadWriteOnce 
  hostPath: 
    path: /volumes/data

---
kubectl create -f pv.yaml 
persistentvolume/localpv createdv

kubectl -n $N get pv,pvc
NAME                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
persistentvolume/localpv   1Gi        RWO            Recycle          Available           localdisk               9m34s

create pvcdeploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: pvcdeploy
  name: pvcdeploy
  namespace: pvdemo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: pvcdeploy
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: pvcdeploy
    spec:
       # add the volumes to the pod spec 
      volumes:
      - name: data
        persistentVolumeClaim: 
          claimName: localpvc
      containers:
      - image: nginx
        name: nginx
        resources: {}

        # Add the volume mounts under the container 
        volumeMounts: 
        - name: data
          mountPath: /tmp/appdata
status: {}


k create -f pvcdeploy.yaml

k -n $N describe deployments.apps pvcdeploy | grep -i mounts -A5

k -n $N get deployments.apps pvcdeploy

PODNAME=`k -n $N get pods -o jsonpath='{.items[0].metadata.name}'`

echo $PODNAME

k -n $N exec $PODNAME -- touch /tmp/appdata/testfile

k -n $N exec $PODNAME -- ls -l /tmp/appdata/testfile
```
