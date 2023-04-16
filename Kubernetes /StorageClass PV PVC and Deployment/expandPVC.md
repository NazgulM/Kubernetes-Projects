# Task

Create a new PersistentVolumeClaim:
Name: pvc-volume-1
Class: hostpath-storage-class
Capacity: 50Mi

Create a new Pod which mounts the PersistentVolumeClaim as a volume:
Name: pvc-pod
Image: nginx
Mount Path: /usr/share/nginx/html

Configure the new Pod to have ReadWriteOnce access on the volume.
Finally,using kubectl edit or Kubectl patch expand the
PersistentVolumeClaim to a capacity of 90Mi and record that change

```
cat > pvc.yaml << EOF
> apiVersion: v1
> kind: PersistentVolumeClaim
> metadata:
>   name: pvc-volume-1
> spec:
>   storageClassName: hostpath-storage-class
>   accessModes:
>     - ReadWriteOnce
>   resources:
>     requests:
>       storage: 50Mi
> 
> EOF
controlplane $ k create -f pvc.yaml
persistentvolumeclaim/pvc-volume-1 created

# DELETING JUST IN CASE IT'S THERE FROM MY PREVIOUS RUN
k delete pod pvc-pod

cat > pod.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: pvc-pod
spec:
  volumes:
   - name: vol
     persistentVolumeClaim:
       claimName: pvc-volume-1
  containers:
  - name: pvc-pod
    image: nginx
    volumeMounts:
    - mountPath: /usr/share/nginx/html
      name: vol

EOF
k create -f pod.yaml
