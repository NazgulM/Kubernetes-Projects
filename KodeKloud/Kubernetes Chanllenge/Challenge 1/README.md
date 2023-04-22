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

Task2; Create static pod static-busybox with image busybox and command sleep 1000 

cp static-busybox.yaml /etc/kubernetes/manifests

Task 3; Expose the hr-web-app as service hr-web-app-service on port 30082 on the nodes. The web app listens the port 8080, type NodePort, endpoints 2, nodePort: 30082

```
k expose deploy hr-web-app --name=hr-web-app-service --target-port=8080 --type=NodePort --port=8080 --dry-run=client -oyaml > hr-web-app-service.yaml

apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: hr-web-app
  name: hr-web-app-service
spec:
  ports:
  - port: 8080
    protocol: TCP
    targetPort: 8080
    nodePort: 30082
  selector:
    app: hr-web-app
  type: NodePort
status:
  loadBalancer: {}

  k scale deploy hr-web-app --replicas=2

k describe svc hr-web-app-service 
Name:                     hr-web-app-service
Namespace:                default
Labels:                   app=hr-web-app
Annotations:              <none>
Selector:                 app=hr-web-app
Type:                     NodePort
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.103.67.202
IPs:                      10.103.67.202
Port:                     <unset>  8080/TCP
TargetPort:               8080/TCP
NodePort:                 <unset>  30082/TCP
Endpoints:                192.168.1.3:8080,192.168.1.4:8080
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```

Task 4; Use JSOn PATH to retrieve the osImage's of all the nodes and store it in a file /opt/outputs/nodes.txt
The osImage are under the nodeInfo section under status of each node.

```
$ k get nodes -o jsonpath='{.items[*].status.nodeInfo.osImage}'
Ubuntu 20.04.5 LTS Ubuntu 20.04.

touch filesystem/opt/nodes_os.txt
k get nodes -o jsonpath='{.items[*].status.nodeInfo.osImage}' > filesystem/opt/nodes_os.txt

cat filesystem/opt/nodes_os.txt
Ubuntu 20.04.5 LTS Ubuntu 20.04.5 LTS
```

Task 5; Create a persistentVolume: name: pv-analytics, storage: 100Mi, Access:ReadWriteMany, hostPath: /pv/data-analytics

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-analytics
  labels:
    type: local
spec:
  capacity:
    storage: 100Mi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: /pv/data-analytics

k create -f pv.yaml 
persistentvolume/pv-analytics created

