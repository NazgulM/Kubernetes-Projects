# Task

Create a persistent volume with name "pv-config"
of capacity "1Gi"
and access mode "ReadWriteMany" 
the type of volume is "hostPath"
and its location is "/tmp/app-config"

```
apiVersion: v1
kind: PersistentVolume
metadata: 
  name: pv-config
spec: 
  capacity: 
    storage: 1Gi
  accessModes: 
   - ReadWriteMany
  hostPath:
    path: /tmp/app-config
```
```
kubectl create -f pv.yaml 
persistentvolume/pv-config created

 k get pv
NAME        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
pv-config   1Gi        RWX            Retain           Available                                   12s
```

