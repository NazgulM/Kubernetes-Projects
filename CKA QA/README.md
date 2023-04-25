# CKA Preparation

1; I have a local Kubernetes cluster with 3 nodes (1 master + 2 workers). One of the worker node is not ready, so no pod can be scheduled on that.
We have to troubleshoot and FIX the issue.

```
kubectl get nodes -o wide
kubectl describe node brokenNode
ssh worker-node02
sudo -i
systemctl status kubelet
cat /etc/kubernetes/kubelet.conf
vi /etc/kubernetes/kubelet.conf 
Fixed to the correct fle name

systemctl daemon-reload
systemctl restart kubelet
systemctl status kubelet

# Went back to the controlPlane
k get nodes
```

2; We have a 3 node cluster setup locally using kubeadm. We need to do the following:

- Create a deployment named web-deploy with the 3 replicas of image mycloudtutorials/poddeployservicedemo:latest in namespace app1
(The Docker container is created from apache image, exposing the application on port 80)

- Pass the following environment variables   NODE_NAME, POD_NAME, POD_IP which are the name of the node where the pod is running, name of the pod and the ip address of the pod respectively

- Verify the pods are working fine, by curl to the individual pods using POD’s internal ip address

- Create a service for this deployment of type NodePort with name web-service in namespace app1 on port 30090

- Check the End points

- Access the service on each of the node:port of the cluster nodes from outside of the cluster

```
k create ns app1
namespace/app1 created

deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: web-deploy
  name: web-deploy
  namespace: app1
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-deploy
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: web-deploy
    spec:
      containers:
      - image: mycloudtutorials/poddeployservicedemo:latest
        name: poddeployservicedemo
        env:
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP

 k -n app1 get deployments.apps 
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
web-deploy   3/3     3            3           11m

 -n app1 get deployments.apps,pods
NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/web-deploy   3/3     3            3           12m

NAME                              READY   STATUS    RESTARTS   AGE
pod/web-deploy-6f4869ff48-5vxbt   1/1     Running   0          12m
pod/web-deploy-6f4869ff48-mj7dz   1/1     Running   0          12m
pod/web-deploy-6f4869ff48-pq4kr   1/1     Running   0          12m

curl -s http://192.168.1.5 
<!DOCTYPE html>
<br />
<b>Warning</b>:  Undefined array key "BGCOLOR" in <b>/var/www/html/index.php</b> on line <b>5</b><br />

<html>
<head>
<style>
    h1 {
    background-color: green;
    }

    div {
        background-color: lightblue    }

</style>
</head>
<body>


<div><p>Hello from mycloudtutorials.com, demoing simple PHP POD, Here are some details about me <br/><br/><ul><li>Pod Name:web-deploy-6f4869ff48-5vxbt</li><li>Pod IP:192.168.1.5</li><li>Running on Node:node01</li></ul></div>
</body>
</html>

apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: web-deploy
  name: web-service
  namespace: app1
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
    nodePort: 30090
  selector:
    app: web-deploy
  type: NodePort
status:
  loadBalancer: {}

  k create -f service.yaml

  k -n app1 get svc,ep
NAME                  TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
service/web-service   NodePort   10.100.109.243   <none>        80:30090/TCP   25s

NAME                    ENDPOINTS                                      AGE
endpoints/web-service   192.168.1.3:80,192.168.1.4:80,192.168.1.5:80   25s
```

3; In the default namespace, we have created 2 deployments frontend and backend. Both deployments are exposed using ClusterIP Services.
  Create a NetworkPolicy named fe-netpol to restrict outgoing TCP connections from frontend deployment and only allow those going to backend deployment.

Note: Make sure the Policy allows outgoing traffic on TCP/UDP ports 53 for DNS resolution.

In our case, we will setup deployment, services from scratch on a local 3 node Kubernetes cluster that I setup using KubeAdm. Then we will test the services are working. We will also test that frontend pod is able to connect to backend-service and outside world (like curl google.com)

After we apply Egress Network Policy, the frontend pods should still be able to connect to backend service, but can not curl google.com. Our NetworkPolicy successfully restricted the outbound connections from the POD.

```
k create deploy backend --image mycloudtutorials/phpbasic:latest --dry-run=client -oyaml > backend.yaml 

apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    tier: backend
  name: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      tier: backend
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        tier: backend
    spec:
      containers:
      - image: mycloudtutorials/phpbasic:latest
        name: phpbasic
        resources: {}
status: {}

k apply -f backend.yaml 
deployment.apps/backend created

k expose deploy backend --name=backend-service --port=80 --target-port=80
service/backend-service exposed

k run tmp1 --image=busybox --restart=Never --rm -i -- wget -O- backend-service
Connecting to backend-service (10.102.134.26:80)
writing to stdout
-                    100% |********************************|   108  0:00:00 ETA
written to stdout
<html>
 <head>
  <title>Basic PHP Page</title>
 </head>
 <body>
    This is backend service
 </body>
</html>pod "tmp1" deleted

k create deploy frontend --image nginx --dry-run=client -oyaml > frontend.yaml

cat frontend.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    tier: frontend
  name: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      tier: frontend
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        tier: frontend
    spec:
      containers:
      - image: nginx
        name: nginx
        resources: {}
status: {}

k get po,deploy
NAME                           READY   STATUS    RESTARTS   AGE
pod/backend-69b69c8bf6-6z59w   1/1     Running   0          3m50s
pod/frontend-64c7db764-rvhx5   1/1     Running   0          22s

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/backend    1/1     1            1           3m50s
deployment.apps/frontend   1/1     1            1           22s

k expose deploy frontend --name=frontend-service --port=80 --target-port=80
service/frontend-service exposed

k get svc,ep
NAME                       TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/backend-service    ClusterIP   10.105.74.68   <none>        80/TCP    17m
service/frontend-service   ClusterIP   10.98.59.107   <none>        80/TCP    6s
service/kubernetes         ClusterIP   10.96.0.1      <none>        443/TCP   9d

NAME                         ENDPOINTS         AGE
endpoints/backend-service    192.168.1.3:80    17m
endpoints/frontend-service   192.168.1.6:80    6s
endpoints/kubernetes         172.30.1.2:6443   9d

k run tmp1 --image=busybox --restart=Never --rm -i -- wget -O- frontend-service
Connecting to frontend-service (10.98.59.107:80)
writing to stdout
-                    100% |********************************|   615  0:00:00 ETA
written to stdout
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
pod "tmp1" deleted

k get po
NAME                       READY   STATUS    RESTARTS   AGE
backend-69b69c8bf6-dhnk2   1/1     Running   0          21m
frontend-64c7db764-2t8hh   1/1     Running   0          9m27s

k exec -it frontend-64c7db764-2t8hh -- sh
# curl backend-service
<html>
 <head>
  <title>Basic PHP Page</title>
 </head>
 <body>
    This is backend service
 </body>
</html># curl google.com
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.com/">here</A>.
</BODY></HTML>

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: fe-netpol
  namespace: default
spec:
  podSelector:
    matchLabels:
      tier: frontend
  policyTypes:
    - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          tier: backend
  - ports:
    - port: 53
      protocol: TCP
    - port: 53
      protocol: UDP

k apply -f fe-netpol.yaml
```

4; Use imperative commands to create a secret name secret1 with key value pairs, username=my_user1, password=P@ssword1

```
k get secrets
No resources found in default namespace.

k create secret generic secret1 --from-literal=username=my_user1 --from-literal=password=P@ssword1
secret/secret1 created

k get secret secret1 -o yaml
apiVersion: v1
data:
  password: UEBzc3dvcmQx
  username: bXlfdXNlcjE=
kind: Secret
metadata:
  creationTimestamp: "2023-04-20T17:45:06Z"
  name: secret1
  namespace: default
  resourceVersion: "3270"
  uid: ee0f02ad-827c-40e8-b9ad-6d64d21a6366
type: Opaque

echo "bXlfdXNlcjE=" | base64 -d
my_user1

echo UEBzc3dvcmQx | base64 -d
P@ssword1
```

Create a yaml file to create a secret named secret2, with key value pairs user2=my_user2, password=P@ssword2, verify the secret was create with the correct data.

echo my_user2 | base64
bXlfdXNlcjIK

echo P@ssword2 | base64
UEBzc3dvcmQyCg==

apiVersion: v1
kind: Secret
metadata:
  name: secret2
data:
  user2: bXlfdXNlcjIK
  password2: UEBzc3dvcmQyCg==

 k apply -f secret.yaml
  get secret secret2 -o yaml
apiVersion: v1
data:
  password2: UEBzc3dvcmQyCg==
  user2: bXlfdXNlcjIK

Create a pod named secretpod1, using image nginx,setup the secret secret1 as volume mount on the pod at path /etc/secret1

cat secretpod1.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: secretpod1
  name: secretpod1
spec:
  volumes:

- name: secret1
    secret:
      secretName: secret1
  containers:
- image: nginx
    name: secretpod1
    volumeMounts:
  - name: secret1
       mountPath: /etc/secret1

k apply -f secretpod1.yaml
pod/secretpod1 created

 k get pods
NAME         READY   STATUS    RESTARTS   AGE
secretpod1   1/1     Running   0          70s

k exec -it secretpod1 -- sh

## ls /etc/secret1

password  username

cat /etc/secret1/username
my_user1

cat /etc/secret1/password
P@ssword1

```

Create a pod named secretpod2 using image nginx.
Pass the following environment variables to the containers
DB_USER: from secret2, key user2
DB_PASSWORD: from secret2, key password2

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: secretpod2
  name: secretpod2
spec:
  containers:
  - image: nginx
    name: secretpod2
    env:
     - name: DB_USER
       valueFrom: 
         secretKeyRef:
           name: secret2
           key: user2
     - name: DB_PASSWORD
       valueFrom:
         secretKeyRef: 
           name: secret2
           key: password2

k apply -f secretpod2.yaml

 k get po
NAME         READY   STATUS    RESTARTS   AGE
secretpod1   1/1     Running   0          22m
secretpod2   1/1     Running   0          4s

k exec -it secretpod2 -- printenv
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=secretpod2
NGINX_VERSION=1.23.4
NJS_VERSION=0.7.11
PKG_RELEASE=1~bullseye
DB_USER=my_user2

DB_PASSWORD=P@ssword2
```
