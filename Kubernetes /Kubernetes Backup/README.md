# Kubernetes backup

```
kubectl get nodes
MASTER=`kubectl get nodes -ojsonpath="{.items[0].metadata.name}"`
echo $MASTER
controlplane

# SHOW EXISTING TAINTS
kubectl describe node $MASTER | grep -i taint

# REMOVE ALL TAINTS
kubectl patch node $MASTER -p '{"spec":{"taints":[]}}'
node/controlplane patched

# CONFIRM TAINT REMOVED
kubectl describe node $MASTER | grep -i taint
Taints:             <none>

# CREATE A POD NAMED BEFORE-BACKUP
kubectl run before-backup --image=nginx

# LET THE POD RUN
kubectl get pods --watch

# BECOME ROOT
sudo -i

# INSTALL ETCD CLIENT
apt install etcd-client

# CHECK THE ETCD CERTIFICATE FILE LOCATION
cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep etcd

# ETCD BACKUP COMMAND

ETCDCTL_API=3 etcdctl snapshot save /tmp/etcd-backup.db --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/apiserver-etcd-client.crt --key /etc/kubernetes/pki/apiserver-etcd-client.key

# CHECK FILE
ls -l /tmp/etcd-backup.db

# EXIT ROOT USER
exit

# CREATE A POD NAMED AFTER-BACKUP
kubectl run after-backup --image=nginx

# LET THE POD RUN
kubectl get pods --watch

# BECOME ROOT
sudo -i 

# REMOVE ALL EXISTING DATA
rm -rf /var/lib/etcd

# ETCD RESTORE COMMAND
ETCDCTL_API=3 etcdctl snapshot restore /tmp/etcd-backup.db --data-dir=/var/lib/etcd
2023-04-14 23:15:33.035719 I | mvcc: restore compact to 7758
2023-04-14 23:15:33.040449 I | etcdserver/membership: added member 8e9e05c52164694d [http://localhost:2380] to cluster cdf818194e3a8c32

# EXIT ROOT USER
exit

kubectl get pods 
NAME            READY   STATUS    RESTARTS   AGE
before-backup   1/1     Running   0          9m33s
```

