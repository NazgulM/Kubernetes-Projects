# CKA LAB 2 - 50 QA

1; Part I:
Create a ClusterIP service .i.e. service-3421-svcn which should expose the pods namely pod-23 and pod-21 with port set to 8080 and targetport to 80.
Part II:
Store the pod names and their ip addresses from all namespaces at /root/pod_ips_cka05_svcn where the output is sorted by their IP's.
Please ensure the format as shown below:
POD_NAME        IP_ADDR
pod-1           ip-1
pod-3           ip-2
pod-2           ip-3
...

```
kubectl get pods --show-labels 
NAME     READY   STATUS    RESTARTS   AGE     LABELS
pod-12   1/1     Running   0          5m21s   env=dev,mode=standard,type=external
pod-34   1/1     Running   0          5m20s   env=dev,mode=standard,type=internal
pod-43   1/1     Running   0          5m20s   env=prod,mode=exam,type=internal
pod-23   1/1     Running   0          5m21s   env=dev,mode=exam,type=external
pod-32   1/1     Running   0          5m20s   env=prod,mode=standard,type=internal
pod-21   1/1     Running   0          5m20s   env=prod,mode=exam,type=external

kubectl get pod -l mode=exam,type=external                                       
NAME     READY   STATUS    RESTARTS   AGE
pod-23   1/1     Running   0          9m18s
pod-21   1/1     Running   0          9m17s

kubectl create service clusterip service-3421-svcn --tcp=8080:80 --dry-run=client -o yaml > service-3421-svcn.yaml

apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: service-3421-svcn
  name: service-3421-svcn
spec:
  ports:
  - name: 8080-80
    port: 8080
    protocol: TCP
    targetPort: 80
  selector:
    app: service-3421-svcn  # delete 
    mode: exam    # add
    type: external  # add
  type: ClusterIP
status:
  loadBalancer: {}

kubectl apply -f service-3421-svcn.yaml
service/service-3421 created

k get ep service-3421-svcn
kubectl get pods -A -o=custom-columns='POD_NAME:metadata.name,IP_ADDR:status.podIP' --sort-by=.status.podIP > /root/pod_ips_cka05_svcn
```

2; Create a ReplicaSet with name checker-cka10-svcn in ns-12345-svcn namespace with image registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3.
Make sure to specify the below specs as well:

command sleep 3600
replicas set to 2
container name: dns-image

Once the checker pods are up and running, store the output of the command nslookup kubernetes.default from any one of the checker pod into the file /root/dns-output-12345-cka10-svcn on student-node.

```
---
apiVersion: v1
kind: Namespace
metadata:
  creationTimestamp: null
  name: ns-12345-svcn
spec: {}
status: {}

---
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: checker-cka10-svcn
  namespace: ns-12345-svcn
  labels:
    app: dns
    tier: testing
spec:
  replicas: 2
  selector:
    matchLabels:
      tier: testing
  template:
    metadata:
      labels:
        tier: testing
    spec:
      containers:
      - name: dns-image
        image: registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3
        command:
          - sleep
          - "3600"

k get pods -n ns-12345-svcn 

POD_NAME=`k get pods -n ns-12345-svcn --no-headers | head -1 | awk '{print $1}'`

kubectl exec -n ns-12345-svcn -i -t $POD_NAME -- nslookup kubernetes.default
;; connection timed out; no servers could be reached

There seems to be a problem with the name resolution. Let's check if our coredns pods are up and if any service exists to reach them:

k get pods -n kube-system | grep coredns
coredns-6d4b75cb6d-cprjz                        1/1     Running   0             42m
coredns-6d4b75cb6d-fdrhv                        1/1     Running   0             42m

k get svc -n kube-system 
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   62m


Everything looks okay here but the name resolution problem exists, let's see if the kube-dns service have any active endpoints:

kubectl get ep -n kube-system kube-dns 
NAME       ENDPOINTS   AGE
kube-dns   <none>      63m

Finally, we have our culprit.
If we dig a little deeper, we will it is using wrong labels and selector:

kubectl describe svc -n kube-system kube-dns 
Name:              kube-dns
Namespace:         kube-system
....
Selector:          k8s-app=core-dns
Type:              ClusterIP
...

kubectl get deploy -n kube-system --show-labels | grep coredns
coredns   2/2     2            2           66m   k8s-app=kube-dns

Let's update the kube-dns service it to point to correct set of pods:

kubectl patch service -n kube-system kube-dns -p '{"spec":{"selector":{"k8s-app": "kube-dns"}}}'
service/kube-dns patched

kubectl get ep -n kube-system kube-dns 
kubectl exec -n ns-12345-svcn -i -t $POD_NAME -- nslookup kubernetes.default
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   kubernetes.default.svc.cluster.local
Address: 10.96.0.1


kubectl exec -n ns-12345-svcn -i -t $POD_NAME -- nslookup kubernetes.default > /root/dns-output-12345-cka10-svcn
```

3; Create a nginx pod called nginx-resolver-cka06-svcn using image nginx, expose it internally with a service called nginx-resolver-service-cka06-svcn.

Test that you are able to look up the service and pod names from within the cluster. Use the image: busybox:1.28 for dns lookup. Record results in /root/CKA/nginx.svc.cka06.svcn and /root/CKA/nginx.pod.cka06.svcn

kubectl run nginx-resolver-cka06-svcn --image=nginx

kubectl expose pod/nginx-resolver-cka06-svcn --name=nginx-resolver-service-cka06-svcn --port=80 --target-port=80 --type=ClusterIP

kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup nginx-resolver-service-cka06-svcn

kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup nginx-resolver-service-cka06-svcn > /root/CKA/nginx.svc.cka06.svcn

Get the IP of the nginx-resolver-cka06-svcn pod and replace the dots(.) with hyphon(-) which will be used below.

kubectl get pod nginx-resolver-cka06-svcn -o wide

IP=`kubectl get pod nginx-resolver-cka06-svcn -o wide --no-headers | awk '{print $6}' | tr

kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup $IP.default.pod > /root/CKA/nginx.pod.cka06.svcn

```

4; Find the node across all clusters that consumes the most memory and store the result to the file /opt/high_memory_node in the following format cluster_name,node_name.

The node could be in any clusters that are currently configured on the student-node.

```

kubectl top node --context cluster1 --no-headers | sort -nr -k4 | head -1
cluster1-controlplane   124m   1%    768Mi   1%

echo cluster3,cluster3-controlplane > /opt/high_memory_node

```

5; An etcd backup is already stored at the path /opt/cluster1_backup_to_restore.db on the cluster1-controlplane node. Use /root/default.etcd as the --data-dir and restore it on the cluster1-controlplane node itself.
You can ssh to the controlplane node by running ssh root@cluster1-controlplane from the student-node.

```

ssh root@cluster1-controlplane
cd /tmp
export RELEASE=$(curl -s <https://api.github.com/repos/etcd-io/etcd/releases/latest> | grep tag_name | cut -d '"' -f 4)
wget <https://github.com/etcd-io/etcd/releases/download/${RELEASE}/etcd-${RELEASE}-linux-amd64.tar.gz>
tar xvf etcd-${RELEASE}-linux-amd64.tar.gz ; cd etcd-${RELEASE}-linux-amd64
mv etcd etcdctl  /usr/local/bin/
etcdctl snapshot restore --data-dir /root/default.etcd /opt/cluster1_backup_to_restore.db

```

6; The db-deployment-cka05-trb deployment is having 0 out of 1 PODs ready.

Figure out the issues and fix the same but make sure that you do not remove any DB related environment variables from the deployment/pod.
```

kubectl get pod
kubectl logs <pod-name>
Error from server (BadRequest): container "db" in pod "db-deployment-cka05-trb-7457c469b7-zbvx6" is waiting to start: CreateContainerConfigError

So let's look into the kubernetes events for this pod:

kubectl get event --field-selector involvedObject.name=<pod-name>

Error: couldn't find key db in Secret default/db-cka05-trb
kubectl get secrets db-root-pass-cka05-trb -o yaml
kubectl get secrets db-user-pass-cka05-trb -o yaml
kubectl get secrets db-cka05-trb -o yaml
kubectl edit deployment db-deployment-cka05-trb -o yaml

You will notice that some of the keys are different what are referred in the deployment.

Change some env keys: db to database , db-user to username and db-password to password
Change a secret reference: db-user-cka05-trb to db-user-pass-cka05-trb
Finally save the changes.

```

7; The deployment called web-dp-cka17-trb has 0 out of 1 pods up and running. Troubleshoot this issue and fix it. Make sure all required POD(s) are in running state and stable (not restarting).
The application runs on port 80 inside the container and is exposed on the node port 30090.

```

kubectl logs grey-cka21-trb --context=cluster4
kubectl get event --context=cluster4 --field-selector involvedObject.name=grey-cka21-trb

kubectl get pod --context=cluster4 -n kube-system
kubectl logs kube-scheduler-cluster4-controlplane --context=cluster4 -n kube-system

"command failed" err="failed to get delegated authentication kubeconfig: failed to get delegated authentication kubeconfig: stat /etc/kubernetes/scheduler.config: no such file or directory"

ssh cluster4-controlplane
ls /etc/kubernetes/scheduler.config

You won't find it, instead the correct file is /etc/kubernetes/scheduler.conf so let's modify the manifest.
vi /etc/kubernetes/manifests/kube-scheduler.yaml

Search for config in the file, you will find some typos, change every occurrence of /etc/kubernetes/scheduler.config to /etc/kubernetes/scheduler.conf.

Let's see if kube-scheduler-cluster4-controlplane is running now

kubectl get pod -A

```

8; On cluster3, there is a web application pod running inside the default namespace. This pod which is part of a deployment called webapp-color-wl10 and makes use of an environment variable that can change constantly. Add this environment variable to a configmap and configure the pod in the deployment to make use of this config map.

Use the following specs-
1. Create a new configMap called webapp-wl10-config-map with the key and value as - APP_COLOR=red.
2. Update the deployment to make use of the newly created configMap name.
3. Delete and recreate the deployment if necessary.

```

apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: webapp-color-wl10
  name: webapp-color-wl10
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: webapp-color-wl10
  template:
    metadata:
      labels:
        app: webapp-color-wl10
    spec:
      containers:
      - image: kodekloud/webapp-color
        name: webapp-color-wl10
        envFrom:
        - configMapRef:
            name: webapp-wl10-config-map

kubectl describe po webapp-color-wl10-d79c6f76c-4gjmz

```

9; We want to deploy a python based application on the cluster using a template located at /root/olive-app-cka10-str.yaml on student-node. However, before you proceed we need to make some modifications to the YAML file as per details given below:

The YAML should also contain a persistent volume claim with name olive-pvc-cka10-str to claim a 100Mi of storage from olive-pv-cka10-str PV.
Update the deployment to add a sidecar container, which can use busybox image (you might need to add a sleep command for this container to keep it running.)
Share the python-data volume with this container and mount the same at path /usr/src. Make sure this container only has read permissions on this volume.
Finally, create a pod using this YAML and make sure the POD is in Running state.

```

---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: olive-pvc-cka10-str
spec:
  accessModes:

- ReadWriteMany
  storageClassName: olive-stc-cka10-str
  volumeName: olive-pv-cka10-str
  resources:
    requests:
      storage: 100Mi

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: olive-app-cka10-str
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: olive-app-cka10-str
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/hostname
                operator: In
                values:
                  - cluster1-node01
      containers:
      - name: python
        image: poroko/flask-demo-app
        ports:
        - containerPort: 5000
        volumeMounts:
        - name: python-data
          mountPath: /usr/share/
      - name: busybox
        image: busybox
        command:
          - "bin/sh"
          - "-c"
          - "sleep 10000"
        volumeMounts:
          - name: python-data
            mountPath: "/usr/src"
            readOnly: true
      volumes:
      - name: python-data
        persistentVolumeClaim:
          claimName: olive-pvc-cka10-str
  selector:
    matchLabels:
      app: olive-app-cka10-str

---
apiVersion: v1
kind: Service
metadata:
  name: olive-svc-cka10-str
spec:
  type: NodePort
  ports:
    - port: 5000
      nodePort: 32006
  selector:
    app: olive-app-cka10-str

k apply -f ...

```

10; Create a storage class with the name banana-sc-cka08-str as per the properties given below:
- Provisioner should be kubernetes.io/no-provisioner,
- Volume binding mode should be WaitForFirstConsumer.
- Volume expansion should be enabled.

```

kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: banana-sc-cka08-str
provisioner: kubernetes.io/no-provisioner
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer

k apply -f fileName

```

11; Create a ReplicaSet with name checker-cka10-svcn in ns-12345-svcn namespace with image registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3.
Make sure to specify the below specs as well:

command sleep 3600
replicas set to 2
container name: dns-image

Once the checker pods are up and running, store the output of the command nslookup kubernetes.default from any one of the checker pod into the file /root/dns-output-12345-cka10-svcn on student-node.
kubectl apply -f - << EOF
---

apiVersion: v1
kind: Namespace
metadata:
  creationTimestamp: null
  name: ns-12345-svcn
spec: {}
status: {}

---
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: checker-cka10-svcn
  namespace: ns-12345-svcn
  labels:
    app: dns
    tier: testing
spec:
  replicas: 2
  selector:
    matchLabels:
      tier: testing
  template:
    metadata:
      labels:
        tier: testing
    spec:
      containers:
      - name: dns-image
        image: registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3
        command:
          - sleep
          - "3600"
EOF

k get pods -n ns-12345-svcn
NAME                       READY   STATUS    RESTARTS   AGE
checker-cka10-svcn-d2cd2   1/1     Running   0          12s
checker-cka10-svcn-qj8rc   1/1     Running   0          12s

POD_NAME=`k get pods -n ns-12345-svcn --no-headers | head -1 | awk '{print $1}'`

kubectl exec -n ns-12345-svcn -i -t $POD_NAME -- nslookup kubernetes.default
;; connection timed out; no servers could be reached

command terminated with exit code 1

k get pods -n kube-system | grep coredns
coredns-6d4b75cb6d-cprjz                        1/1     Running   0             42m
coredns-6d4b75cb6d-fdrhv                        1/1     Running   0             42m

  k get svc -n kube-system
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   6

kubectl describe svc -n kube-system kube-dns
Name:              kube-dns
Namespace:         kube-system
....
Selector:          k8s-app=core-dns
Type:              ClusterIP
...

kubectl get deploy -n kube-system --show-labels | grep coredns
coredns   2/2     2            2           66m   k8s-app=kube-dns

```

12; Part I:

Create a ClusterIP service .i.e. service-3421-svcn which should expose the pods namely pod-23 and pod-21 with port set to 8080 and targetport to 80.

Part II:
Store the pod names and their ip addresses from all namespaces at /root/pod_ips_cka05_svcn where the output is sorted by their IP's.

Please ensure the format as shown below:

POD_NAME        IP_ADDR
pod-1           ip-1
pod-3           ip-2
pod-2           ip-3
...

```

The easiest way to route traffic to a specific pod is by the use of labels and selectors . List the pods along with their labels:

kubectl get pods --show-labels
NAME     READY   STATUS    RESTARTS   AGE     LABELS
pod-12   1/1     Running   0          5m21s   env=dev,mode=standard,type=external
pod-34   1/1     Running   0          5m20s   env=dev,mode=standard,type=internal
pod-43   1/1     Running   0          5m20s   env=prod,mode=exam,type=internal
pod-23   1/1     Running   0          5m21s   env=dev,mode=exam,type=external
pod-32   1/1     Running   0          5m20s   env=prod,mode=standard,type=internal
pod-21   1/1     Running   0          5m20s   env=prod,mode=exam,type=external

Looks like there are a lot of pods created to confuse us. But we are only concerned with the labels of pod-23 and pod-21.

As we can see both the required pods have labels mode=exam,type=external in common. Let's confirm that using kubectl too:

kubectl get pod -l mode=exam,type=external
NAME     READY   STATUS    RESTARTS   AGE
pod-23   1/1     Running   0          9m18s
pod-21   1/1     Running   0          9m17s

Nice!! Now as we have figured out the labels, we can proceed further with the creation of the service:

kubectl create service clusterip service-3421-svcn --tcp=8080:80 --dry-run=client -o yaml > service-3421-svcn.yaml

Now modify the service definition with selectors as required before applying to k8s cluster:

cat service-3421-svcn.yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: service-3421-svcn
  name: service-3421-svcn
spec:
  ports:

- name: 8080-80
    port: 8080
    protocol: TCP
    targetPort: 80
  selector:
    app: service-3421-svcn  # delete
    mode: exam    # add
    type: external  # add
  type: ClusterIP
status:
  loadBalancer: {}

Finally let's apply the service definition:

kubectl apply -f service-3421-svcn.yaml
service/service-3421 created

k get ep service-3421-svcn
NAME           ENDPOINTS                     AGE
service-3421   10.42.0.15:80,10.42.0.17:80   52s

kubectl get pods -A -o=custom-columns='POD_NAME:metadata.name,IP_ADDR:status.podIP' --sort-by=.status.podIP

POD_NAME                                  IP_ADDR
helm-install-traefik-crd-lbwzr            10.42.0.2
local-path-provisioner-7b7dc8d6f5-d4x7t   10.42.0.3
metrics-server-668d979685-vh7bk           10.42.0.4
...

# store the output to /root/pod_ips

 kubectl get pods -A -o=custom-columns='POD_NAME:metadata.name,IP_ADDR:status.podIP' --sort-by=.status.podIP > /root/pod_ips_cka05_svcn

```

13; Create a loadbalancer service with name wear-service-cka09-svcn to expose the deployment webapp-wear-cka09-svcn application in app-space namespace.

```

kubectl expose -n app-space deployment webapp-wear-cka09-svcn --type=LoadBalancer --name=wear-service-cka09-svcn --port=8080
service/wear-service-cka09-svcn exposed

k get svc -n app-space
NAME                      TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
wear-service-cka09-svcn   LoadBalancer   10.43.68.233   172.25.0.14   8080:32109/TCP   14s

```

14; For this question, please set the context to cluster1 by running:
kubectl config use-context cluster1
Create a pod with name tester-cka02-svcn in dev-cka02-svcn namespace with image registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3. Make sure to use command sleep 3600 with restart policy set to Always .

Once the tester-cka02-svcn pod is running, store the output of the command nslookup kubernetes.default from tester pod into the file /root/dns_output on student-node.

```

Create the pod as per the requirements:

kubectl apply -f - << EOF
apiVersion: v1
kind: Pod
metadata:
  name: tester-cka02-svcn
  namespace: dev-cka02-svcn
spec:
  containers:

- name: tester-cka02-svcn
    image: registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3
    command:
  - sleep
  - "3600"
  restartPolicy: Always
EOF

Now let's test if the nslookup command is working :
kubectl exec -n dev-cka02-svcn -i -t tester-cka02-svcn -- nslookup kubernetes.default
;; connection timed out; no servers could be reached

command terminated with exit code 1

Looks like something is broken at the moment, if we observe the kube-system namespace, we will see no coredns pods are not running which is creating the problem, let's scale them for the nslookup command to work:

kubectl scale deployment -n kube-system coredns --replicas=2

Now let store the correct output into the /root/dns_output on student-node :

kubectl exec -n dev-cka02-svcn -i -t tester-cka02-svcn -- nslookup kubernetes.default >> /root/dns_output

We should have something similar to below output:

cat /root/dns_output
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   kubernetes.default.svc.cluster.local
Address: 10.96.0.1

```

15; Run a pod called looper-cka16-arch using the busybox image that runs the while loop while true; do echo hello; sleep 10;done. This pod should be created in the default namespace.

```

apiVersion: v1
kind: Pod
metadata:
  name: looper-cka16-arch
spec:
  containers:

- name: busybox
    image: busybox
    command: ["/bin/sh", "-c", "while true; do echo hello; sleep 10;done"]
    kubectl apply -f looper-cka16-arch.yaml --context cluster3

```

16;There is a deployment called nginx-dp-cka04-trb which has been used to deploy a static website. The access to this website can be tested by running: curl <http://kodekloud-exam.app:30002>. However, it is not working at the moment.
Troubleshoot and fix it.

```

kubectl logs -f <pod-name>
kubectl get event --field-selector involvedObject.name=<pod-name>

 Warning   FailedMount   pod/nginx-dp-cka04-trb-767b767dc-6c5wk   Unable to attach or mount volumes: unmounted volumes=[nginx-config-volume-cka04-trb], unattached volumes=[index-volume-cka04-trb kube-api-access-4fbrb nginx-config-volume-cka04-trb]: timed out waiting for the condition

 From the error we can see that its not able to mount nginx-config-volume-cka04-trb volume

Check the nginx-dp-cka04-trb deployment
kubectl get deploy nginx-dp-cka04-trb -o=yaml

Under volumes: look for the configMap: name which is nginx-configuration-cka04-trb. Now lets look into this configmap.

kubectl get configmap

ou will see an configmap named nginx-config-cka04-trb which seems to be the correct one.

Edit the nginx-dp-cka04-trb deployment now

kubectl edit deploy nginx-dp-cka04-trb

Under configMap: change nginx-configuration-cka04-trb to nginx-config-cka04-trb. Once done wait for the POD to come up.

Try to access the website now:

curl <http://kodekloud-exam.app:30002>

```

17; Solution cyan

```
kubectl edit networkpolicy cyan-np-cka28-trb -n cyan-ns-cka28-trb
Under spec: -> egress: you will notice there is not cidr: block has been added, since there is no restrictions on egress traffic so we can update it as below. Further you will notice that the port used in the policy is 8080 but the app is running on default port which is 80 so let's update this as well (under egress and ingress):

Change port: 8080 to port: 80

- ports:
  - port: 80
    protocol: TCP
  to:
  - ipBlock:
      cidr: 0.0.0.0/0

ow, lastly notice that there is no POD selector has been used in ingress section but this app is supposed to be accessible from cyan-white-cka28-trb pod under default namespace. So let's edit it to look like as below:

ingress:

- from:
  - namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: default
   podSelector:
      matchLabels:
        app: cyan-white-cka28-trb

kubectl exec -it cyan-white-cka28-trb -- sh
curl cyan-svc-cka28-trb.cyan-ns-cka28-trb.svc.cluster.local

kubectl exec -it cyan-black-cka28-trb -- sh
curl cyan-svc-cka28-trb.cyan-ns-cka28-trb.svc.cluster.local

```

18; A pod called nginx-cka01-trb is running in the default namespace. There is a container called nginx-container running inside this pod that uses the image nginx:latest. There is another sidecar container called logs-container that runs in this pod.

For some reason, this pod is continuously crashing. Identify the issue and fix it. Make sure that the pod is in a running state and you are able to access the website using the curl <http://kodekloud-exam.app:30001> command on the controlplane node of cluster1.

```

kubectl logs -f nginx-cka01-trb -c nginx-container
kubectl edit pod nginx-cka01-trb -o yaml
Change image tag from nginx:latst to nginx:latest

kubectl logs -f nginx-cka01-trb -c nginx-container
kubectl logs -f nginx-cka01-trb -c logs-container

cat: can't open '/var/log/httpd/access.log': No such file or directory
cat: can't open '/var/log/httpd/error.log': No such file or directory

Under containers: check the command: section, this is the command which is failing. If you notice its looking for the logs under /var/log/httpd/ directory but the mounted volume for logs is /var/log/nginx (under volumeMounts:). So we need to fix this path:

kubectl get pod nginx-cka01-trb -o yaml > /tmp/test.yaml
vi /tmp/test.yaml

Under command: change /var/log/httpd/access.log and /var/log/httpd/error.log to /var/log/nginx/access.log and /var/log/nginx/error.log respectively.

Delete the existing POD now:

kubectl delete pod nginx-cka01-trb
Create new one from the template

kubectl apply -f /tmp/test.yaml
Let's check now if the POD is in Running state

kubectl get pod
It should be good now. So let's try to access the app.

curl <http://kodekloud-exam.app:30001>
You will see error

curl: (7) Failed to connect to kodekloud-exam.

Edit the service
kubectl edit svc nginx-service-cka01-trb -o yaml
Change app label under selector from httpd-app-cka01-trb to nginx-app-cka01-trb
You should be able to access the website now.
curl <http://kodekloud-exam.app:30001>

```

19; demo-pod-cka29-trb pod is stuck in aPending state, look into issue to fix the same, Make sure pod is in Running state and stable.

```

Look into the POD events
kubectl get event --field-selector involvedObject.name=demo-pod-cka29-trb
You will see some Warnings like:

Warning   FailedScheduling   pod/demo-pod-cka29-trb   0/3 nodes are available: 3 pod has unbound immediate PersistentVolumeClaims. preemption: 0/3 nodes are available: 3 Preemption is not helpful for scheduling.
This seems to be something related to PersistentVolumeClaims, Let's check that:

kubectl get pvc
You will notice that demo-pvc-cka29-trb is stuck in Pending state. Let's dig into it

kubectl get event --field-selector involvedObject.name=demo-pvc-cka29-trb
You will notice this error:

Warning   VolumeMismatch   persistentvolumeclaim/demo-pvc-cka29-trb   Cannot bind to requested volume "demo-pv-cka29-trb": incompatible accessMode
Which means the PVC is using incompatible accessMode, let's check the it out

kubectl get pvc demo-pvc-cka29-trb -o yaml
kubectl get pv demo-pv-cka29-trb -o yaml
Let's re-create the PVC with correct access mode i.e ReadWriteMany

kubectl get pvc demo-pvc-cka29-trb -o yaml > /tmp/pvc.yaml
vi /tmp/pvc.yaml
Under spec: change accessModes: from ReadWriteOnce to ReadWriteMany
Delete the old PVC and create new

kubectl delete pvc demo-pvc-cka29-trb
kubectl apply -f /tmp/pvc.yaml
Check the POD now

kubectl get pod demo-pod-cka29-trb
It should be good now.

```

20; The pink-depl-cka14-trb Deployment was scaled to 2 replicas however, the current replicas is still 1.

Troubleshoot and fix this issue. Make sure the CURRENT count is equal to the DESIRED count.

You can SSH into the cluster4 using ssh cluster4-controlplane command.

```
kubectl get deployment
We can see DESIRED count for pink-depl-cka14-trb is 2 but the CURRENT count is still 1

As we know Kube Controller Manager is responsible for monitoring the status of replica sets/deployments and ensuring that the desired number of PODs are available so let's check if its running fine.

kubectl get pod -n kube-system
So kube-controller-manager-cluster4-controlplane is crashing, let's check the events to figure what's happening

kubectl get event --field-selector involvedObject.name=kube-controller-manager-cluster4-controlplane -n kube-system

Warning   NodeNotReady   pod/kube-controller-manager-cluster4-controlplane   Node is not ready
3m25s       Normal    Killing        pod/kube-controller-manager-cluster4-controlplane   Stopping container kube-controller-manager
2m18s       Normal    Pulled         pod/kube-controller-manager-cluster4-controlplane   Container image "k8s.gcr.io/kube-controller-manager:v1.24.0" already present on machine
2m18s       Normal    Created        pod/kube-controller-manager-cluster4-controlplane   Created container kube-controller-manager
2m18s       Warning   Failed         pod/kube-controller-manager-cluster4-controlplane   Error: failed to create containerd task: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: exec: "kube-controller-manage": executable file not found in $PATH: unknown
108s        Warning   BackOff        pod/kube-controller-manager-cluster4-controlplane   Back-off restarting failed container


Warning   Failed    pod/kube-controller-manager-cluster4-controlplane   Error: failed to create containerd task: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: exec: "kube-controller-manage": executable file not found in $PATH: unknown
Seems like its trying to run kube-controller-manage command but it is supposed to run kube-controller-manager commmand. So lets look into the kube-controller-manager manifest which is present under /etc/kubernetes/manifests/kube-controller-manager.yaml on cluster4-controlplane node. So let's SSH into cluster4-controlplane

ssh cluster4-controlplane
vi /etc/kubernetes/manifests/kube-controller-manager.yaml
Under containers: -> - command: change kube-controller-manage to kube-controller-manager and restart kube-controller-manager-cluster4-controlplane POD
kubectl delete pod kube-controller-manager-cluster4-controlplane -n kube-system
Check now the ReplicaSet
kubectl get deployment
CURRENT count should be equal to the DESIRED count now for pink-depl-cka14-trb.

```

21; We have deployed a 2-tier web application on the cluster3 nodes in the canara-wl05 namespace. However, at the moment, the web app pod cannot establish a connection with the MySQL pod successfully.
You can check the status of the application from the terminal by running the curl command with the following syntax:
curl <http://cluster3-controlplane:NODE-PORT>

To make the application work, create a new secret called db-secret-wl05 with the following key values: -

1. DB_Host=mysql-svc-wl05
2. DB_User=root
3. DB_Password=password123

Next, configure the web application pod to load the new environment variables from the newly created secret.
Note: Check the web application again using the curl command, and the status of the application should be success.
You can SSH into the cluster3 using ssh cluster3-controlplane command.

```
ssh cluster2-controlplane

curl <http://10.17.63.11:31020>
<!doctype html>
<title>Hello from Flask</title>
...

    <img src="/static/img/failed.png">
    <h3> Failed connecting to the MySQL database. </h3>


    <h2> Environment Variables: DB_Host=Not Set; DB_Database=Not Set; DB_User=Not Set; DB_Password=Not Set; 2003: Can&#39;t connect to MySQL server on &#39;localhost:3306&#39; (111 Connection refused) </h2>

kubectl create secret generic db-secret-wl05 -n canara-wl05 --from-literal=DB_Host=mysql-svc-wl05 --from-literal=DB_User=root --from-literal=DB_Password=password123
After that, configure the newly created secret to the web application pod as follows: -

---
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: webapp-pod-wl05
  name: webapp-pod-wl05
  namespace: canara-wl05
spec:
  containers:

- image: kodekloud/simple-webapp-mysql
    name: webapp-pod-wl05
    envFrom:
  - secretRef:
        name: db-secret-wl05
then use the kubectl replace command: -

kubectl replace -f <FILE-NAME> --force

In the end, make use of the curl command to check the status of the application pod. The status of the application should be success.

curl <http://10.17.63.11:31020>

<!doctype html>
<title>Hello from Flask</title>
<body style="background: #39b54b;"></body>
<div style="color: #e4e4e4;
    text-align:  center;
    height: 90px;
    vertical-align:  middle;">

    <img src="/static/img/success.jpg">
    <h3> Successfully connected to the MySQL database

```

22;A pod called check-time-cka03-trb is continuously crashing. Figure out what is causing this and fix it.
Make sure that the check-time-cka03-trb POD is in running state.
This pod prints the current date and time at a pre-defined frequency and saves it to a file. Ensure that it continues this operation once you have fixed it.

```
kubectl logs -f check-time-cka03-trb

Look into the POD events
kubectl get event --field-selector involvedObject.name=check-time-cka03-trb
You will see an error something like:

Error: failed to create containerd task: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: exec: "/bin/bash": stat /bin/bash: no such file or directory: unknown
From the error we can see that its not able to execute /bin/bash so let's try /bin/sh

Edit the pod
kubectl get pod check-time-cka03-trb -o=yaml > check-time-cka03-trb.yaml
Make the required changes in check-time-cka03-trb.yaml template
vi check-time-cka03-trb.yaml
Under spec: -> containers: -> command: change /bin/bash to /bin/sh and save the file.

Delete the old pod.
kubectl delete pod check-time-cka03-trb

Apply the updated template
kubectl apply -f check-time-cka03-trb.yaml
```

23; There is a pod called pink-pod-cka16-trb created in the default namespace in cluster4. This app runs on port tcp/5000 and it is exposed to end-users using an ingress resource called pink-ing-cka16-trb in such a way that it is supposed to be accessible using the command: curl <http://kodekloud-pink.app> on cluster4-controlplane host.
However, this is not working. Troubleshoot and fix this issue, making any necessary to the objects.
Note: You should be able to ssh into the cluster4-controlplane using ssh cluster4-controlplane command.

```
SSH into the cluster4-controlplane host and try to access the app.
ssh cluster4-controlplane

curl kodekloud-pink.app
You must be getting 503 Service Temporarily Unavailable error.
Let's look into the service:

kubectl edit svc pink-svc-cka16-trb
Under ports: change protocol: UDP to protocol: TCP
Try to access the app again

curl kodekloud-pink.app
You must be getting curl: (6) Could not resolve host: example.com error, from the error we can see that its not able to resolve example.com host which indicated that it can be some issue related to the DNS. As we know CoreDNS is a DNS server that can serve as the Kubernetes cluster DNS, so it can be something related to CoreDNS.

Let's check if we have CoreDNS deployment running:

kubectl get deploy -n kube-system
You will see that for coredns all replicas are down, you will see 0/0 ready pods. So let's scale up this deployment.

kubectl scale --replicas=2 deployment coredns -n kube-system
Once CoreDBS is up let's try to access to app again.

curl kodekloud-pink.app
It should work now.
```

24; The cat-cka22-trb pod is stuck in Pending state. Look into the issue to fix the same. Make sure that the pod is in running state and its stable (i.e not restarting or crashing).
Note: Do not make any changes to the pod (No changes to pod config but you may destroy and re-create).

```
Let's check the POD status
kubectl get pod
You will see that cat-cka22-trb pod is stuck in Pending state. So let's try to look into the events

kubectl --context cluster2 get event --field-selector involvedObject.name=cat-cka22-trb
You will see some logs as below

Warning   FailedScheduling   pod/cat-cka22-trb   0/3 nodes are available: 1 node(s) had untolerated taint {node-role.kubernetes.io/master: }, 2 node(s) didn't match Pod's node affinity/selector. preemption: 0/2 nodes are available: 3 Preemption is not helpful for scheduling.
So seems like this POD is using the node affinity, let's look into the POD to understand the node affinity its using.

kubectl --context cluster2 get pod cat-cka22-trb -o yaml
Under affinity: you will see its looking for key: node and values: cluster2-node01 so let's verify if node01 has these labels applied.

kubectl --context cluster2 get node cluster2-node01 -o yaml
Look under labels: and you will not find any such label, so let's add this label to this node.

kubectl label node cluster1-node01 node=cluster2-node01
Check again the node details

kubectl get node cluster2-node01 -o yaml
The new label should be there, let's see if POD is scheduled now on this node

kubectl --context cluster2 get pod
Its is but it must be crashing or restarting, so let's look into the pod logs

kubectl --context cluster2 logs -f cat-cka22-trb
You will see logs as below:

The HOST variable seems incorrect, it must be set to kodekloud
Let's look into the POD env variables to see if there is any HOST env variable

kubectl --context cluster2 get pod -o yaml
Under env: you will see this

env:
- name: HOST
  valueFrom:
    secretKeyRef:
      key: hostname
      name: cat-cka22-trb
So we can see that HOST variable is defined and its value is being retrieved from a secret called "cat-cka22-trb". Let's look into this secret.

kubectl --context cluster2 get secret
kubectl --context cluster2 get secret cat-cka22-trb -o yaml
You will find a key/value pair under data:, let's try to decode it to see its value:

echo "<the decoded value you see for hostname" | base64 -d
ok so the value is set to kodekloude which is incorrect as it should be set to kodekloud. So let's update the secret:

echo "kodekloud" | base64
kubectl edit secret cat-cka22-trb
Change requests storage hostname: a29kZWtsb3Vkdg== to hostname: a29kZWtsb3VkCg== (values may vary)
POD should be good now.
```

25; There is a requirement to share a volume between two containers that are running within the same pod. Use the following instructions to create the pod and related objects:

- Create a pod named grape-pod-cka06-str.
- The main container should use the nginx image and mount a volume called grape-vol-cka06-str at path /var/log/nginx.
- The sidecar container can use busybox image, you might need to add a sleep command to this container to keep it running. Next, mount the same volume called grape-vol-cka06-str at the path /usr/src.
- The volume should be of type emptyDir.

```
apiVersion: v1
kind: Pod
metadata:
  name: grape-pod-cka06-str
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
      - name: grape-vol-cka06-str
        mountPath: "/var/log/nginx"
  - name: busybox
    image: busybox
    command:
      - "bin/sh"
      - "-c"
      - "sleep 10000"
    volumeMounts:
      - name: grape-vol-cka06-str
        mountPath: "/usr/src"
  volumes:
  - name: grape-vol-cka06-str
    emptyDir: {}
```

26; Create a nginx pod called nginx-resolver-cka06-svcn using image nginx, expose it internally with a service called nginx-resolver-service-cka06-svcn.
Test that you are able to look up the service and pod names from within the cluster. Use the image: busybox:1.28 for dns lookup. Record results in /root/CKA/nginx.svc.cka06.svcn and /root/CKA/nginx.pod.cka06.svcn

```
To create a pod nginx-resolver-cka06-svcn and expose it internally:
kubectl run nginx-resolver-cka06-svcn --image=nginx 
kubectl expose pod/nginx-resolver-cka06-svcn --name=nginx-resolver-service-cka06-svcn --port=80 --target-port=80 --type=ClusterIP 

To create a pod test-nslookup. Test that you are able to look up the service and pod names from within the cluster:

 kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup nginx-resolver-service-cka06-svcn
 kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup nginx-resolver-service-cka06-svcn > /root/CKA/nginx.svc.cka06.svcn

Get the IP of the nginx-resolver-cka06-svcn pod and replace the dots(.) with hyphon(-) which will be used below.


 kubectl get pod nginx-resolver-cka06-svcn -o wide
 IP=`kubectl get pod nginx-resolver-cka06-svcn -o wide --no-headers | awk '{print $6}' | tr '.' '-'`
 kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup $IP.default.pod > /root/CKA/nginx.pod.cka06.svcn
 ```

 27; Create a loadbalancer service with name wear-service-cka09-svcn to expose the deployment webapp-wear-cka09-svcn application in app-space namespace.

 ```
kubectl expose -n app-space deployment webapp-wear-cka09-svcn --type=LoadBalancer --name=wear-service-cka09-svcn --port=8080
service/wear-service-cka09-svcn exposed

k get svc -n app-space
NAME                      TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
wear-service-cka09-svcn   LoadBalancer   10.43.68.233   172.25.0.14   8080:32109/TCP   14s
```

28; Create a pod with name tester-cka02-svcn in dev-cka02-svcn namespace with image registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3. Make sure to use command sleep 3600 with restart policy set to Always .
Once the tester-cka02-svcn pod is running, store the output of the command nslookup kubernetes.default from tester pod into the file /root/dns_output on student-node.

```
Since the "dev-cka02-svcn" namespace doesn't exist, let's create it first:

kubectl create ns dev-cka02-svcn

kubectl apply -f - << EOF
apiVersion: v1
kind: Pod
metadata:
  name: tester-cka02-svcn
  namespace: dev-cka02-svcn
spec:
  containers:
  - name: tester-cka02-svcn
    image: registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3
    command:
      - sleep
      - "3600"
  restartPolicy: Always
EOF

kubectl exec -n dev-cka02-svcn -i -t tester-cka02-svcn -- nslookup kubernetes.default
;; connection timed out; no servers could be reached

Looks like something is broken at the moment, if we observe the kube-system namespace, we will see no coredns pods are not running which is creating the problem, let's scale them for the nslookup command to work:


kubectl scale deployment -n kube-system coredns --replicas=2

Now let store the correct output into the /root/dns_output on student-node :

kubectl exec -n dev-cka02-svcn -i -t tester-cka02-svcn -- nslookup kubernetes.default >> /root/dns_output

We should have something similar to below output:
cat /root/dns_output
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   kubernetes.default.svc.cluster.local
Address: 10.96.0.1
```

29; Create a service account called pink-sa-cka24-arch. Further create a cluster role called pink-role-cka24-arch with full permissions on all resources in the core api group under default namespace in cluster1.
Finally create a cluster role binding called pink-role-binding-cka24-arch to bind pink-role-cka24-arch cluster role with pink-sa-cka24-arch service account.

```
kubectl --context cluster1 create serviceaccount pink-sa-cka24-arch
kubectl --context cluster1 create clusterrole pink-role-cka24-arch --resource=* --verb=*
kubectl --context cluster1 create clusterrolebinding pink-role-binding-cka24-arch --clusterrole=pink-role-cka24-arch --serviceaccount=default:pink-sa-cka24-arch
```

30; There is a script located at /root/pod-cka26-arch.sh on the student-node. Update this script to add a command to filter/display the label with value component of the pod called kube-apiserver-cluster1-controlplane (on cluster1) using jsonpath.

```
kubectl --context cluster1 get pod -n kube-system kube-apiserver-cluster1-controlplane  -o jsonpath='{.metadata.labels.component}'
vi pod-cka26-arch.sh
```

31; A template to create a Kubernetes pod is stored at /root/red-probe-cka12-trb.yaml on the student-node. However, using this template as-is is resulting in an error.
Fix the issue with this template and use it to create the pod. Once created, watch the pod for a minute or two to make sure its stable i.e, it's not crashing or restarting.
Make sure you do not update the args: section of the template.

```
kubectl apply -f red-probe-cka12-trb.yaml 
You will see error:

error: error validating "red-probe-cka12-trb.yaml": error validating data: [ValidationError(Pod.spec.containers[0].livenessProbe.httpGet): unknown field "command" in io.k8s.api.core.v1.HTTPGetAction, ValidationError(Pod.spec.containers[0].livenessProbe.httpGet): missing required field "port" in io.k8s.api.core.v1.HTTPGetAction]; if you choose to ignore these errors, turn validation off with --validate=false
From the error you can see that the error is for liveness probe, so let's open the template to find out:

vi red-probe-cka12-trb.yaml
Under livenessProbe: you will see the type is httpGet however the rest of the options are command based so this probe should be of exec type.

Change httpGet to exec
Try to apply the template now
kubectl apply -f red-probe-cka12-trb.yaml 
Cool it worked, now let's watch the POD status, after few seconds you will notice that POD is restarting. So let's check the logs/events

kubectl get event --field-selector involvedObject.name=red-probe-cka12-trb
You will see an error like:

Unhealthy   pod/red-probe-cka12-trb   Liveness probe failed: cat: can't open '/healthcheck': No such file or directory
So seems like Liveness probe is failing, lets look into it:

vi red-probe-cka12-trb.yaml
Notice the command - sleep 3 ; touch /healthcheck; sleep 30;sleep 30000 it starts with a delay of 3 seconds, but the liveness probe initialDelaySeconds is set to 1 and failureThreshold is also 1. Which means the POD will fail just after first attempt of liveness check which will happen just after 1 second of pod start. So to make it stable we must increase the initialDelaySeconds to at least 5

vi red-probe-cka12-trb.yaml
Change initialDelaySeconds from 1 to 5 and save apply the changes.
Delete old pod:

kubectl delete pod red-probe-cka12-trb
Apply changes:

kubectl apply -f red-probe-cka12-trb.yaml
```

32; On cluster4 we are having some weird issue where we are intermittently getting below error while running kubectl commands.

The connection to the server cluster4-controlplane:6443 was refused - did you specify the right host or port?
Whenever you get this error, you can wait for 10-15 seconds to make kubectl command work again, but it will come again after few second
We also noticed that kube-controller-manager-cluster4-controlplane pod is restarting continuously. Look into the issue and troubleshoot the same.
You can SSH into the cluster4 using ssh cluster4-controlplane command.

```
kubectl get pod --context=cluster4 -n kube-system
You will see that kube-controller-manager-cluster4-controlplane pod is crashing or restarting. So let's try to watch the logs.

kubectl logs -f kube-controller-manager-cluster4-controlplane --context=cluster4 -n kube-system
You will see some logs as below:

kube-system/kube-controller-manager: Get "https://10.10.129.21:6443/apis/coordination.k8s.io/v1/namespaces/kube-system/leases/kube-controller-manager?timeout=5s": dial tcp 10.10.129.21:6443: connect: connection refused
You will notice that somehow the connection to the kube api is breaking, let's check if kube api pod is healthy.

kubectl get pod --context=cluster4 -n kube-system
Now you might notice that kube-apiserver-cluster4-controlplane pod is also restarting, so we should dig into its logs or relevant events.

kubectl logs -f kube-apiserver-cluster4-controlplane -n kube-system
kubectl get event --field-selector involvedObject.name=kube-apiserver-cluster4-controlplane -n kube-system
In events you will see this error

kube-apiserver-cluster4-controlplane   Liveness probe failed: Get "https://10.10.132.25:6444/livez": dial tcp 10.10.132.25:6444: connect: connection refused
From this we can see that the Liveness probe is failing for the kube-apiserver-cluster4-controlplane pod, and we can see its trying to connect to port 6444 port but the default api port is 6443. So let's look into the kube api server manifest.

ssh cluster4-controlplane
vi /etc/kubernetes/manifests/kube-apiserver.yaml
Under livenessProbe: you will see the port: value is 6444, change it to 6443 and save. Now wait for few seconds let the kube api pod come up.

kubectl get pod -n kube-system
Watch the PODs status for some time and make sure these are not restarting now.
```

33; We recently deployed a DaemonSet called logs-cka26-trb under kube-system namespace in cluster2 for collecting logs from all the cluster nodes including the controlplane node. However, at this moment, the DaemonSet is not creating any pod on the controlplane node.
Troubleshoot the issue and fix it to make sure the pods are getting created on all nodes including the controlplane node.

```
kubectl --context2 cluster2 get pod  -n kube-system
You can check on which nodes these are created on

kubectl --context2 cluster2 get pod <pod-name> -n kube-system -o wide
Under NODE you will find the node name, so we can see that its not scheduled on the controlplane node which is because it must be missing the reqiured tolerations. Let's edit the DaemonSet to fix the tolerations

kubectl --context2 cluster2 edit ds logs-cka26-trb -n kube-system
Under tolerations: add below given tolerations as well

- key: node-role.kubernetes.io/control-plane
  operator: Exists
  effect: NoSchedule
Wait for some time PODs should schedule on all nodes now including the controlplane node.
```

34; Create a new deployment called ocean-tv-wl09 in the default namespace using the image kodekloud/webapp-color:v1.
Use the following specs for the deployment:

1. Replica count should be 3.
2. Set the Max Unavailable to 40% and Max Surge to 55%.
3. Create the deployment and ensure all the pods are ready.
4. After successful deployment, upgrade the deployment image to kodekloud/webapp-color:v2 and inspect the deployment rollout status.
5. Check the rolling history of the deployment and on the student-node, save the current revision count number to the /opt/revision-count.txt file.
6. Finally, perform a rollback and revert back the deployment image to the older version.

```
Use the following template to create a deployment called ocean-tv-wl09: -

---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: ocean-tv-wl09
  name: ocean-tv-wl09
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ocean-tv-wl09
  strategy: 
   type: RollingUpdate
   rollingUpdate:
     maxUnavailable: 40%
     maxSurge: 55%
  template:
    metadata:
      labels:
        app: ocean-tv-wl09
    spec:
      containers:
      - image: kodekloud/webapp-color:v1
        name: webapp-color

Now, create the deployment by using the kubectl create -f command in the default namespace: -
kubectl create -f <FILE-NAME>.yaml

After sometime, upgrade the deployment image to kodekloud/webapp-color:v2: -

kubectl set image deploy ocean-tv-wl09 webapp-color=kodekloud/webapp-color:v2

And check out the rollout history of the deployment ocean-tv-wl09: -

kubectl rollout history deploy ocean-tv-wl09
deployment.apps/ocean-tv-wl09 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>

NOTE: - Revision count is 2. In your lab, it could be different.

On the student-node, store the revision count to the given file: 
echo "2" > /opt/revision-count.txt

In final task, rollback the deployment image to an old version: -

kubectl rollout undo deployment ocean-tv-wl09

Verify the image name by using the following command: -
kubectl describe deploy ocean-tv-wl09

It should be kodekloud/webapp-color:v1 image.
```

35; A pod definition file is created at /root/peach-pod-cka05-str.yaml on the student-node. Update this manifest file to create a persistent volume claim called peach-pvc-cka05-str to claim a 100Mi of storage from peach-pv-cka05-str PV (this is already created). Use the access mode ReadWriteOnce.
Further add peach-pvc-cka05-str PVC to peach-pod-cka05-str POD and mount the volume at /var/www/html location. Ensure that the pod is running and the PV is bound.

```
Set context to cluster1

Update /root/peach-pod-cka05-str.yaml template file to create a PVC to utilise the same in POD template.
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: peach-pvc-cka05-str
spec:
  volumeName: peach-pv-cka05-str
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 100Mi
---
apiVersion: v1
kind: Pod
metadata:
  name: peach-pod-cka05-str
spec:
  containers:
  - image: nginx
    name: nginx
    volumeMounts:
      - mountPath: "/var/www/html"
        name: nginx-volume
  volumes:
    - name: nginx-volume
      persistentVolumeClaim:
        claimName: peach-pvc-cka05-str
Apply the template:
kubectl apply -f /root/peach-pod-cka05-str.yaml
```

36; Create a nginx pod called nginx-resolver-cka06-svcn using image nginx, expose it internally with a service called nginx-resolver-service-cka06-svcn.
Test that you are able to look up the service and pod names from within the cluster. Use the image: busybox:1.28 for dns lookup. Record results in /root/CKA/nginx.svc.cka06.svcn and /root/CKA/nginx.pod.cka06.svcn

```
To create a pod nginx-resolver-cka06-svcn and expose it internally:

kubectl run nginx-resolver-cka06-svcn --image=nginx kubectl expose pod/nginx-resolver-cka06-svcn --name=nginx-resolver-service-cka06-svcn --port=80 --target-port=80 --type=ClusterIP 

To create a pod test-nslookup. Test that you are able to look up the service and pod names from within the cluster:

 kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup nginx-resolver-service-cka06-svcn kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup nginx-resolver-service-cka06-svcn > /root/CKA/nginx.svc.cka06.svcn

Get the IP of the nginx-resolver-cka06-svcn pod and replace the dots(.) with hyphon(-) which will be used below.
 kubectl get pod nginx-resolver-cka06-svcn -o wide IP=`kubectl get pod nginx-resolver-cka06-svcn -o wide --no-headers | awk '{print $6}' | tr '.' '-'` kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup $IP.default.pod > /root/CKA/nginx.pod.cka06.svcn
```

37; Deploy a messaging-cka07-svcn pod using the redis:alpine image with the labels set to tier=msg.
Now create a service messaging-service-cka07-svcn to expose the messaging-cka07-svcn application within the cluster on port 6379.

```
On student-node, use the command 
kubectl run messaging-cka07-svcn --image=redis:alpine -l tier=msg
Now run the command: 
kubectl expose pod messaging-cka07-svcn --port=6379 --name messaging-service-cka07-svcn
```

38; Create a ReplicaSet with name checker-cka10-svcn in ns-12345-svcn namespace with image registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3.
Make sure to specify the below specs as well:

command sleep 3600
replicas set to 2
container name: dns-image

Once the checker pods are up and running, store the output of the command nslookup kubernetes.default from any one of the checker pod into the file /root/dns-output-12345-cka10-svcn on student-node.

```
kubectl apply -f - << EOF
---
apiVersion: v1
kind: Namespace
metadata:
  creationTimestamp: null
  name: ns-12345-svcn
spec: {}
status: {}

---
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: checker-cka10-svcn
  namespace: ns-12345-svcn
  labels:
    app: dns
    tier: testing
spec:
  replicas: 2
  selector:
    matchLabels:
      tier: testing
  template:
    metadata:
      labels:
        tier: testing
    spec:
      containers:
      - name: dns-image
        image: registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3
        command:
          - sleep
          - "3600"
EOF

Now let's test if the nslookup command is working :

k get pods -n ns-12345-svcn 
NAME                       READY   STATUS    RESTARTS   AGE
checker-cka10-svcn-d2cd2   1/1     Running   0          12s
checker-cka10-svcn-qj8rc   1/1     Running   0          12s

POD_NAME=`k get pods -n ns-12345-svcn --no-headers | head -1 | awk '{print $1}'`

kubectl exec -n ns-12345-svcn -i -t $POD_NAME -- nslookup kubernetes.default
;; connection timed out; no servers could be reached

command terminated with exit code 1



There seems to be a problem with the name resolution. Let's check if our coredns pods are up and if any service exists to reach them:



k get pods -n kube-system | grep coredns
coredns-6d4b75cb6d-cprjz                        1/1     Running   0             42m
coredns-6d4b75cb6d-fdrhv                        1/1     Running   0             42m

k get svc -n kube-system 
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   62m

Everything looks okay here but the name resolution problem exists, let's see if the kube-dns service have any active endpoints:

kubectl get ep -n kube-system kube-dns 
NAME       ENDPOINTS   AGE
kube-dns   <none>      63m

Finally, we have our culprit.
If we dig a little deeper, we will it is using wrong labels and selector:

kubectl describe svc -n kube-system kube-dns 
Name:              kube-dns
Namespace:         kube-system
....
Selector:          k8s-app=core-dns
Type:              ClusterIP
...

kubectl get deploy -n kube-system --show-labels | grep coredns
coredns   2/2     2            2           66m   k8s-app=kube-dns

Let's update the kube-dns service it to point to correct set of pods:

kubectl patch service -n kube-system kube-dns -p '{"spec":{"selector":{"k8s-app": "kube-dns"}}}'
service/kube-dns patched

kubectl get ep -n kube-system kube-dns 
NAME       ENDPOINTS                                              AGE
kube-dns   10.50.0.2:53,10.50.192.1:53,10.50.0.2:53 + 3 more...   69m

kubectl exec -n ns-12345-svcn -i -t $POD_NAME -- nslookup kubernetes.default
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   kubernetes.default.svc.cluster.local
Address: 10.96.0.1

kubectl exec -n ns-12345-svc
```

39; Create a loadbalancer service with name wear-service-cka09-svcn to expose the deployment webapp-wear-cka09-svcn application in app-space namespace.
info_outline

```
kubectl expose -n app-space deployment webapp-wear-cka09-svcn --type=LoadBalancer --name=wear-service-cka09-svcn --port=8080
service/wear-service-cka09-svcn exposed

k get svc -n app-space
NAME                      TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
wear-service-cka09-svcn   LoadBalancer   10.43.68.233   172.25.0.14   8080:32109/TCP   14s
```

40; There is a deployment called nodeapp-dp-cka08-trb created in the default namespace on cluster1. This app is using an ingress resource named nodeapp-ing-cka08-trb.

From cluster1-controlplane host we should be able to access this app using the command: curl <http://kodekloud-ingress.app>. However, it is not working at the moment. Troubleshoot and fix the issue.

Note: You should be able to ssh into the cluster1-controlplane using ssh cluster1-controlplane command.

```
SSh into cluster1-controlplane
ssh cluster1-controlplane
Try to access the app using curl http://kodekloud-ingress.app command. You will see 404 Not Found error.

Look into the ingress to make sure its configured properly.

kubectl get ingress
kubectl edit ingress nodeapp-ing-cka08-trb
Under rules: -> host: change example.com to kodekloud-ingress.app
Under backend: -> service: -> name: Change example-service to nodeapp-svc-cka08-trb
Change port: -> number: from 80 to 3000
You should be able to access the app using curl http://kodekloud-ingress.app command now.
```

41; There is a pod called pink-pod-cka16-trb created in the default namespace in cluster4. This app runs on port tcp/5000 and it is exposed to end-users using an ingress resource called pink-ing-cka16-trb in such a way that it is supposed to be accessible using the command: curl <http://kodekloud-pink.app> on cluster4-controlplane host.
However, this is not working. Troubleshoot and fix this issue, making any necessary to the objects.
Note: You should be able to ssh into the cluster4-controlplane using ssh cluster4-controlplane command.

```
SSH into the cluster4-controlplane host and try to access the app.
ssh cluster4-controlplane
curl kodekloud-pink.app
You must be getting 503 Service Temporarily Unavailabl error.
Let's look into the service:

kubectl edit svc pink-svc-cka16-trb
Under ports: change protocol: UDP to protocol: TCP
Try to access the app again

curl kodekloud-pink.app
You must be getting curl: (6) Could not resolve host: example.com error, from the error we can see that its not able to resolve example.com host which indicated that it can be some issue related to the DNS. As we know CoreDNS is a DNS server that can serve as the Kubernetes cluster DNS, so it can be something related to CoreDNS.

Let's check if we have CoreDNS deployment running:

kubectl get deploy -n kube-system
You will see that for coredns all replicas are down, you will see 0/0 ready pods. So let's scale up this deployment.

kubectl scale --replicas=2 deployment coredns -n kube-system
Once CoreDBS is up let's try to access to app again.

curl kodekloud-pink.app
```

42; Create a new deployment called ocean-tv-wl09 in the default namespace using the image kodekloud/webapp-color:v1.
Use the following specs for the deployment:

1. Replica count should be 3.
2. Set the Max Unavailable to 40% and Max Surge to 55%.
3. Create the deployment and ensure all the pods are ready.
4. After successful deployment, upgrade the deployment image to kodekloud/webapp-color:v2 and inspect the deployment rollout status.
5. Check the rolling history of the deployment and on the student-node, save the current revision count number to the /opt/revision-count.txt file.
6. Finally, perform a rollback and revert back the deployment image to the older version.

```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: ocean-tv-wl09
  name: ocean-tv-wl09
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ocean-tv-wl09
  strategy: 
   type: RollingUpdate
   rollingUpdate:
     maxUnavailable: 40%
     maxSurge: 55%
  template:
    metadata:
      labels:
        app: ocean-tv-wl09
    spec:
      containers:
      - image: kodekloud/webapp-color:v1
        name: webapp-color


kubectl create -f <FILE-NAME>.yaml

kubectl set image deploy ocean-tv-wl09 webapp-color=kodekloud/webapp-color:v2

kubectl rollout history deploy ocean-tv-wl09
deployment.apps/ocean-tv-wl09 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>

echo "2" > /opt/revision-count.txt
kubectl rollout undo deployment ocean-tv-wl09
kubectl describe deploy ocean-tv-wl09
It should be kodekloud/webapp-color:v1 image.
```

43; Set context to cluster.

Create a yaml file as below:
apiVersion: v1
kind: Pod
metadata:
  name: grape-pod-cka06-str
spec:
  containers:

- name: nginx
    image: nginx
    volumeMounts:
  - name: grape-vol-cka06-str
        mountPath: "/var/log/nginx"
- name: busybox
    image: busybox
    command:
  - "bin/sh"
  - "-c"
  - "sleep 10000"
    volumeMounts:
  - name: grape-vol-cka06-str
        mountPath: "/usr/src"
  volumes:
- name: grape-vol-cka06-str
    emptyDir: {}
Apply the template:
kubectl apply -f <template-file-name>.yaml

```

44; To create a pod nginx-resolver-cka06-svcn and expose it internally:

student-node ~ ➜ kubectl run nginx-resolver-cka06-svcn --image=nginx 
student-node ~ ➜ kubectl expose pod/nginx-resolver-cka06-svcn --name=nginx-resolver-service-cka06-svcn --port=80 --target-port=80 --type=ClusterIP 

To create a pod test-nslookup. Test that you are able to look up the service and pod names from within the cluster:

student-node ~ ➜  kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup nginx-resolver-service-cka06-svcn
student-node ~ ➜  kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup nginx-resolver-service-cka06-svcn > /root/CKA/nginx.svc.cka06.svcn

Get the IP of the nginx-resolver-cka06-svcn pod and replace the dots(.) with hyphon(-) which will be used below.

student-node ~ ➜  kubectl get pod nginx-resolver-cka06-svcn -o wide
student-node ~ ➜  IP=`kubectl get pod nginx-resolver-cka06-svcn -o wide --no-headers | awk '{print $6}' | tr '.' '-'`
student-node ~ ➜  kubectl run test-nslookup --im

45; On student-node, use the command: kubectl create deployment hr-web-app-cka08-svcn --image=kodekloud/webapp-color --replicas=2

Now we can run the command: kubectl expose deployment hr-web-app-cka08-svcn --type=NodePort --port=8080 --name=hr-web-app-service-cka08-svcn --dry-run=client -o yaml > hr-web-app-service-cka08-svcn.yaml to generate a service definition file.

Now, in generated service definition file add the nodePort field with the given port number under the ports section and create a service.

46; kubectl --context cluster1 get pod -n kube-system kube-apiserver-cluster1-controlplane  -o jsonpath='{.metadata.labels.component}'

47; SSH into cluster1-controlplane node:

student-node ~ ➜ ssh root@cluster1-controlplane
Install etcd utility (if not installed already) and restore the backup:
cluster1-controlplane ~ ➜ cd /tmp
cluster1-controlplane ~ ➜ export RELEASE=$(curl -s https://api.github.com/repos/etcd-io/etcd/releases/latest | grep tag_name | cut -d '"' -f 4)
cluster1-controlplane ~ ➜ wget https://github.com/etcd-io/etcd/releases/download/${RELEASE}/etcd-${RELEASE}-linux-amd64.tar.gz
cluster1-controlplane ~ ➜ tar xvf etcd-${RELEASE}-linux-amd64.tar.gz ; cd etcd-${RELEASE}-linux-amd64
cluster1-controlplane ~ ➜ mv etcd etcdctl  /usr/local/bin/
cluster1-controlplane ~ ➜ etcdctl snapshot restore --data-dir /root/default.etcd /opt/cluster1_backup_to_restore.db 


ETCDCTL_API=3 etcdctl --data-dir /root/default.etcd snapshot restore /opt/cluster1_backup_to_restore.db

48; 
```

apiVersion: v1
kind: Pod
metadata:
  name: looper-cka16-arch
spec:
  containers:

- name: busybox
    image: busybox
    command: ["/bin/sh", "-c", "while true; do echo hello; sleep 10;done"]

```

49; 
```

kubectl get pod
Most probably you see Init:Error or Init:CrashLoopBackOff for the corresponding pod.

Look into the logs
kubectl logs blue-dp-cka09-trb-xxxx -c init-container
You will see an error something like

sh: can't open 'echo 'Welcome!'': No such file or directory
Edit the deployment
kubectl edit deploy blue-dp-cka09-trb
Under initContainers: -> - command: add -c to the next line of - sh, so final command should look like this
   initContainers:

- command:
  - sh
  - -c
  - echo 'Welcome!'
If you will check pod then it must be failing again but with different error this time, let's find that out

kubectl get event --field-selector involvedObject.name=blue-dp-cka09-trb-xxxxx
You will see an error something like

Warning   Failed      pod/blue-dp-cka09-trb-69dd844f76-rv9z8   Error: failed to create containerd task: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: error during container init: error mounting "/var/lib/kubelet/pods/98182a41-6d6d-406a-a3e2-37c33036acac/volumes/kubernetes.io~configmap/nginx-config" to rootfs at "/etc/nginx/nginx.conf": mount /var/lib/kubelet/pods/98182a41-6d6d-406a-a3e2-37c33036acac/volumes/kubernetes.io~configmap/nginx-config:/etc/nginx/nginx.conf (via /proc/self/fd/6), flags: 0x5001: not a directory: unknown
Edit the deployment again
kubectl edit deploy blue-dp-cka09-trb
Under volumeMounts: -> - mountPath: /etc/nginx/nginx.conf -> name: nginx-config add subPath: nginx.conf and save the changes.
Finally the pod should be in running state.

```

50; 
```

Let's look into the network policy

kubectl edit networkpolicy cyan-np-cka28-trb -n cyan-ns-cka28-trb
Under spec: -> egress: you will notice there is not cidr: block has been added, since there is no restrcitions on egress traffic so we can update it as below. Further you will notice that the port used in the policy is 8080 but the app is running on default port which is 80 so let's update this as well (under egress and ingress):

Change port: 8080 to port: 80

- ports:
  - port: 80
    protocol: TCP
  to:
  - ipBlock:
      cidr: 0.0.0.0/0
Now, lastly notice that there is no POD selector has been used in ingress section but this app is supposed to be accessible from cyan-white-cka28-trb pod under default namespace. So let's edit it to look like as below:

ingress:

- from:
  - namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: default
   podSelector:
      matchLabels:
        app: cyan-white-cka28-trb
Now, let's try to access the app from cyan-white-pod-cka28-trb

kubectl exec -it cyan-white-cka28-trb -- sh
curl cyan-svc-cka28-trb.cyan-ns-cka28-trb.svc.cluster.local
Also make sure its not accessible from the other pod(s)

kubectl exec -it cyan-black-cka28-trb -- sh
curl cyan-svc-cka28-trb.cyan-ns-cka28-trb.svc.cluster.local
It should not work from this pod. So its looking good now.

```


```

kubectl get deployment --output=custom-columns="DEPLOYMENT:.metadata.name,CONTAINER_IMAGE:.spec.template.spec.containers[*].image,READY_REPLICAS:.status.readyReplicas,NAMESPACE:.metadata.namespace" --sort-by=.metadata.name
```
