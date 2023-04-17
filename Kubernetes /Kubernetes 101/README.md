# Tasks

1; Create a Multi-container Pod with the name multi-c-pod, which has containers from the following images:

- image1 : nginx:alpine
- image2 : redis
- image3 : memcached

You can have container names, as per your choice.

```
apiVersion: v1
kind: Pod
metadata:
  name: multi-c-pod
spec:
  containers: 
  - name: con1
    image: nginx:alpine
  - name: con2
    image: redis
  - name: con3
    image: memcached
```

Q2. Create a Namespace with name mynamespace using a YAML configuration file. Create a Pod in this namespace with the name mypod . Use nginx:alpine image for Container.

```
apiVersion: v1
kind: Namespace
metadata:
  creationTimestamp: "2023-04-16T20:04:23Z"
  labels:
    kubernetes.io/metadata.name: mynamespace
  name: mynamespace
  resourceVersion: "4686"
  uid: 6ddccc5b-fa20-4076-9de8-dccd5779a1df
spec:
  finalizers:
  - kubernetes
status:
  phase: Active
```

```
k get pods
NAME          READY   STATUS    RESTARTS   AGE
multi-c-pod   3/3     Running   0          11m

k get pods -n mynamespace 
NAME    READY   STATUS    RESTARTS   AGE
mypod   1/1     Running   0          8m
```

```
k create deploy --image=nginx nginx-deploy 
kubectl scale deployment nginx-deploy --replicas=1
kubectl get deploy
kubectl get pods

Scaling up the Deployment to 2 Replicas
kubectl scale deployment nginx-deploy --replicas=2
k get pods
```

RollingOut the app with new version
Updating the image version for our container

```
kubectl set image deployment/nginx-deploy nginx=nginx:stable
deployment.apps/nginx-deploy image updated

# Checkout the RollOut status
k rollout status deployment nginx-deploy
deployment "nginx-deploy" successfully rolled out

k set image deployment/nginx-deploy nginx=nginx:latest
deployment.apps/nginx-deploy image updated
```

```
kubectl get deploy,rs,pods
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-deploy   3/3     3            3           7s

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-deploy-774f96d4d9   3         3         3       7s

NAME                                READY   STATUS    RESTARTS   AGE
pod/nginx-deploy-774f96d4d9-8m57h   1/1     Running   0          7s
pod/nginx-deploy-774f96d4d9-p4p4h   1/1     Running   0          7s
pod/nginx-deploy-774f96d4d9-t4bgr   1/1     Running   0          7s

# Updating the image version for our container

k set image deployment/nginx-deploy nginx=nginx:stable 
deployment.apps/nginx-deploy image updated

k rollout status deployment nginx-deploy 
deployment "nginx-deploy" successfully rolled out

# Let's update it one more time and watch the ReplicaSet changes. 

k set image deployment/nginx-deploy nginx=nginx:latest
deployment.apps/nginx-deploy image updated

k get rs -w
NAME                      DESIRED   CURRENT   READY   AGE
nginx-deploy-66b9f7ff85   3         3         3       16s
nginx-deploy-69b948c8fc   0         0         0       2m34s
nginx-deploy-774f96d4d9   0         0         0       3m28s
