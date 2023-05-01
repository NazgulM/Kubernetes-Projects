# CKA LAB 3

1; Set the correct context: -

kubectl config use-context cluster3
List the nodes: -

kubectl get nodes -o wide
Run the curl command to know the status of the application as follows: -

ssh cluster2-controlplane

curl http://10.17.63.11:31020
<!doctype html>
<title>Hello from Flask</title>
...

    <img src="/static/img/failed.png">
    <h3> Failed connecting to the MySQL database. </h3>


    <h2> Environment Variables: DB_Host=Not Set; DB_Database=Not Set; DB_User=Not Set; DB_Password=Not Set; 2003: Can&#39;t connect to MySQL server on &#39;localhost:3306&#39; (111 Connection refused) </h2>


As you can see, the status of the application pod is failed.


NOTE: - In your lab, IP addresses could be different.
Let's create a new secret called db-secret-wl05 as follows: -

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

curl http://10.17.63.11:31020

<!doctype html>
<title>Hello from Flask</title>
<body style="background: #39b54b;"></body>
<div style="color: #e4e4e4;
    text-align:  center;
    height: 90px;
    vertical-align:  middle;">


    <img src="/static/img/success.jpg">
    <h3> Successfully connected to the MySQL database.</h3>

2; 
```First set the context to cluster1

kubectl config use-context cluster1
Create a yaml template as below:
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: coconut-pv-cka01-str
  labels: 
    storage-tier: gold
spec:
  capacity:
    storage: 100Mi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: /opt/coconut-stc-cka01-str
  storageClassName: coconut-stc-cka01-str
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - cluster1-node01
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: coconut-pvc-cka01-str
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 50Mi
  storageClassName: coconut-stc-cka01-str
  selector: 
    matchLabels:
      storage-tier: gold
      
kubectl apply -f <template-name>.yaml
```

3; 
```
Let's check if the webserver is working or not:

curl student-node:9999
...
<h1>Welcome to nginx!</h1>
...

Now we will check if service is correctly defined:

kubectl describe svc external-webserver-cka03-svcn 
Name:              external-webserver-cka03-svcn
Namespace:         default
.
.
Endpoints:         <none> # there are no endpoints for the service
...

As we can see there is no endpoints specified for the service, hence we won't be able to get any output. Since we can not destroy any k8s object, let's create the endpoint manually for this service as shown below:

export IP_ADDR=$(ifconfig eth0 | grep inet | awk '{print $2}')

kubectl --context cluster3 apply -f - <<EOF
apiVersion: v1
kind: Endpoints
metadata:
  # the name here should match the name of the Service
  name: external-webserver-cka03-svcn
subsets:
  - addresses:
      - ip: $IP_ADDR
    ports: 
      - port: 9999
EOF

Finally check if the curl test works now:

kubectl --context cluster3 run --rm  -i test-curl-pod --image=curlimages/curl --restart=Never -- curl -m 2 external-webserver-cka03-svcn
...
<title>Welcome to nginx!</title>
```

4; 
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



To store all the pod name along with their IP's , we could use imperative command as shown below:



kubectl get pods -A -o=custom-columns='POD_NAME:metadata.name,IP_ADDR:status.podIP' --sort-by=.status.podIP

POD_NAME                                  IP_ADDR
helm-install-traefik-crd-lbwzr            10.42.0.2
local-path-provisioner-7b7dc8d6f5-d4x7t   10.42.0.3
metrics-server-668d979685-vh7bk           10.42.0.4
...

# store the output to /root/pod_ips
kubectl get pods -A -o=custo
```

5; 
```
Change to the cluster4 context before attempting the task:

kubectl config use-context cluster3



Create the ReplicaSet as per the requirements:



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

kubectl describe svc -n kube-system kube-dns 
Name:              kube-dns
Namespace:         kube-system
....
Selector:          k8s-app=core-dns
Type:              ClusterIP
...

kubectl get deploy -n kube-system --show-labels | grep coredns
coredns   2/2     2            2           66m   k8s-app=kube-dns

kubectl patch service -n kube-system kube-dns -p '{"spec":{"selector":{"k8s-app": "kube-dns"}}}'
service/kube-dns patched

kubectl get ep -n kube-system kube-dns 
NAME       ENDPOINTS                                              AGE
kube-dns   10.50.0.2:53,10.50.192.1:53,10.50.0.2:53 + 3 more...   69m

NOTE: We can use any method to update kube-dns service. In our case, we have used kubectl patch command.

Now let's store the correct output to /root/dns-output-12345-cka10-svcn:

kubectl exec -n ns-12345-svcn -i -t $POD_NAME -- nslookup kubernetes.default
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   kubernetes.default.svc.cluster.local
Address: 10.96.0.1


kubectl exec -n ns-12345-svcn -i -t $POD_NAME -- nslookup kubernetes.default > /root/dns-output-12345-cka10-svcn
```

6; 
```
Test if the service curlme-cka01-svcn is accessible from pod curlpod-cka01-svcn or not.


kubectl exec curlpod-cka01-svcn -- curl curlme-cka01-svcn

.....
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:10 --:--:--     0


We did not get any response. Check if the service is properly configured or not.


kubectl describe svc curlme-cka01-svcn ''

....
Name:              curlme-cka01-svcn
Namespace:         default
Labels:            <none>
Annotations:       <none>
Selector:          run=curlme-ckaO1-svcn
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.109.45.180
IPs:               10.109.45.180
Port:              <unset>  80/TCP
TargetPort:        80/TCP
Endpoints:         <none>
Session Affinity:  None
Events:            <none>


The service has no endpoints configured. As we can delete the resource, let's delete the service and create the service again.

To delete the service, use the command kubectl delete svc curlme-cka01-svcn.
You can create the service using imperative way or declarative way.

apiVersion: v1
kind: Service
metadata:
  labels:
    run: curlme-cka01-svcn
  name: curlme-cka01-svcn
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    run: curlme-cka01-svcn
  type: ClusterIP


You can test the connection from curlpod-cka-1-svcn using following.
kubectl exec curlpod-cka01-svcn -- curl curlme-cka01-svcn
```

7; kubectl logs logger-cka03-arch --context cluster3 > /root/logger-cka03-arch-all

8; 
```
kubectl create ns secure-sys-cka12-arch --context cluster3

kubectl create secret generic secure-sec-cka12-arch --from-literal=color=darkblue -n secure-sys-cka12-arch --context cluster3
```

9; 
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

21s         Warning   Unhealthy   pod/red-probe-cka12-trb   Liveness probe failed: cat: can't open '/healthcheck': No such file or directory
So seems like Liveness probe is failing, lets look into it:

vi red-probe-cka12-trb.yaml
Notice the command - sleep 3 ; touch /healthcheck; sleep 30;sleep 30000 it starts with a delay of 3 seconds, but the liveness probe initialDelaySeconds is set to 1 and failureThreshold is also 1. Which means the POD will fail just after first attempt of liveness check which will happen just after 1 second of pod start. So to make it stable we must increase the initialDelaySeconds to at least 5

vi red-probe-cka12-trb.yaml
Change initialDelaySeconds from 1 to 5 and save apply the changes.

kubectl delete pod red-probe-cka12-trb
Apply changes:

kubectl apply -f red-probe-cka12-trb.yaml
```

10; 
```
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
You will see that for coredns all relicas are down, you will see 0/0 ready pods. So let's scale up this deployment.

kubectl scale --replicas=2 deployment coredns -n kube-system
Once CoreDBS is up let's try to access to app again.

curl kodekloud-pink.app
```

11; 
```
kubectl describe svc external-webserver-cka03-svcn 

export IP_ADDR=$(ifconfig eth0 | grep inet | awk '{print $2}')

kubectl --context cluster3 apply -f - <<EOF
apiVersion: v1
kind: Endpoints
metadata:
  # the name here should match the name of the Service
  name: external-webserver-cka03-svcn
subsets:
  - addresses:
      - ip: $IP_ADDR
    ports:
      - port: 9999
EOF
kubectl --context cluster3 run --rm  -i test-curl-pod --image=curlimages/curl --restart=Never -- curl -m 2 external-webserver-cka03-svcn
...
<title>Welcome to nginx!</title>
```

12; 
```
kubectl expose -n app-space deployment webapp-wear-cka09-svcn --type=LoadBalancer --name=wear-service-cka09-svcn --port=8080
service/wear-service-cka09-svcn exposed

k get svc -n app-space

wear-service-cka09-svcn   LoadBalancer   10.43.68.233   172.25.0.14   8080:32109/TCP   14s
```

26; 
```
kubectl top node --context cluster1 --no-headers | sort -nr -k2 | head -1
cluster1-controlplane   127m   1%    703Mi   1%    

echo cluster3,cluster3-controlplane > /opt/high_cpu_node
```

27;

```
List the PVC to check its status
kubectl  get pvc
So we can see orange-pvc-cka13-trb PVC is in Pending state and its requesting a storage of 150Mi. Let's look into the events

kubectl get events --sort-by='.metadata.creationTimestamp' -A
You will see some errors as below:

Warning   VolumeMismatch            persistentvolumeclaim/orange-pvc-cka13-trb          Cannot bind to requested volume "orange-pv-cka13-trb": requested PV is too small
Let's look into orange-pv-cka13-trb volume

kubectl get pv
We can see that orange-pv-cka13-trb volume is of 100Mi capacity which means its too small to request 150Mi of storage.
Let's edit orange-pvc-cka13-trb PVC to adjust the storage requested.

kubectl get pvc orange-pvc-cka13-trb -o yaml > /tmp/orange-pvc-cka13-trb.yaml
vi /tmp/orange-pvc-cka13-trb.yaml
Under resources: -> requests: -> storage: change 150Mi to 100Mi and save.
Delete old PVC and apply the change:

kubectl delete pvc orange-pvc-cka13-trb
kubectl apply -f /tmp/orange-pvc-cka13-trb.yaml 
```

28; 
```
et's check the POD status
kubectl get pod --context=cluster4 -n kube-system
You will see that kube-controller-manager-cluster4-controlplane pod is crashing or restarting. So let's try to watch the logs.

kubectl logs -f kube-controller-manager-cluster4-controlplane --context=cluster4 -n kube-system
You will see some logs as below:

 error retrieving resource lock kube-system/kube-controller-manager: Get "https://10.10.129.21:6443/apis/coordination.k8s.io/v1/namespaces/kube-system/leases/kube-controller-manager?timeout=5s": dial tcp 10.10.129.21:6443: connect: connection refused
You will notice that somehow the connection to the kube api is breaking, let's check if kube api pod is healthy.

kubectl get pod --context=cluster4 -n kube-system
Now you might notice that kube-apiserver-cluster4-controlplane pod is also restarting, so we should dig into its logs or relevant events.

kubectl logs -f kube-apiserver-cluster4-controlplane -n kube-system
kubectl get event --field-selector involvedObject.name=kube-apiserver-cluster4-controlplane -n kube-system
In events you will see this error

Warning   Unhealthy      pod/kube-apiserver-cluster4-controlplane   Liveness probe failed: Get "https://10.10.132.25:6444/livez": dial tcp 10.10.132.25:6444: connect: connection refused
From this we can see that the Liveness probe is failing for the kube-apiserver-cluster4-controlplane pod, and we can see its trying to connect to port 6444 port but the default api port is 6443. So let's look into the kube api server manifest.

ssh cluster4-controlplane
vi /etc/kubernetes/manifests/kube-apiserver.yaml
Under livenessProbe: you will see the port: value is 6444, change it to 6443 and save. Now wait for few seconds let the kube api pod come up.

kubectl get pod -n kube-system
Watch the PODs status for some time and make sure these are not restarting now.
```

29; 
```
Let's create a new secret called db-secret-wl05 as follows: -

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

curl http://10.17.63.11:31020

<!doctype html>
<title>Hello from Flask</title>
<body style="background: #39b54b;"></body>
<div style="color: #e4e4e4;
    text-align:  center;
    height: 90px;
    vertical-align:  middle;">


    <img src="/static/img/success.jpg">
    <h3> Successfully connected to the MySQL database.</h3>
```

30; 
```
student-node ~ ➜ kubectl run nginx-resolver-cka06-svcn --image=nginx 
student-node ~ ➜ kubectl expose pod/nginx-resolver-cka06-svcn --name=nginx-resolver-service-cka06-svcn --port=80 --target-port=80 --type=ClusterIP 



To create a pod test-nslookup. Test that you are able to look up the service and pod names from within the cluster:


kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup nginx-resolver-service-cka06-svcnkubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup nginx-resolver-service-cka06-svcn > /root/CKA/nginx.svc.cka06.svcn

Get the IP of the nginx-resolver-cka06-svcn pod and replace the dots(.) with hyphon(-) which will be used below.
kubectl get pod nginx-resolver-cka06-svcn -o wideIP=`kubectl get pod nginx-resolver-cka06-svcn -o wide --no-headers | awk '{print $6}' | tr '.' '-'`kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup $IP.default.pod > /root/CKA/nginx.pod.cka06.svcn
```

31; 
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

kubectl describe svc -n kube-system kube-dns 
Name:              kube-dns
Namespace:         kube-system
....
Selector:          k8s-app=core-dns
Type:              ClusterIP
...
kubectl get deploy -n kube-system --show-labels | grep coredns
coredns   2/2     2            2           66m   k8s-app=kube-dns


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

kubectl exec -n ns-12345-svcn -i -t $POD_NAME -- nslookup kubernetes.default > /root/dns-output-12345-cka10-svcn
```

32; 
```
kubectl apply -f - << EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress-cka04-svcn
  annotations:
    ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-service-cka04-svcn
            port:
              number: 80
EOF


kubectl get ingress
NAME                       CLASS    HOSTS   ADDRESS       PORTS   AGE
nginx-ingress-cka04-svcn   <none>   *       172.25.0.10   80      13s

As the ingress controller is exposed on cluster3-controlplane using service, we need to ssh to cluster3-controlplane first to check if the ingress resource works properly:


ssh cluster3-controlplane

cluster3-controlplane:~# curl -I 172.25.0.11
HTTP/1.1 200 OK
...
```

33; 