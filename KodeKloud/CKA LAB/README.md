# LAB QA

1; Decode the existing secret called beta-sec-cka14-arch created in the beta-ns-cka14-arch namespace and store the decoded content inside the file /opt/beta-sec-cka14-arch on the student-node.

```
k get secret beta-sec-cka14-arch -n beta-ns-cka14-arch
NAME                  TYPE     DATA   AGE
beta-sec-cka14-arch   Opaque   1      2m19s

k get secret beta-sec-cka14-arch -n beta-ns-cka14-arch -o jsonpath='{.data}'
{"secret":"VGhpcyBpcyB0aGUgc2VjcmV0IQo="}

echo "VGhpcyBpcyB0aGUgc2VjcmV0IQo=" | base64 -d
This is the secret!

echo "VGhpcyBpcyB0aGUgc2VjcmV0IQo=" | base64 -d > /opt/beta-sec-cka14-arch

cat /opt/beta-sec-cka14-arch
This is the secret!
```

2; A pod called logger-complete-cka04-arch has been created in the default namespace. Inspect this pod and save ALL the logs to the file /root/logger-complete-cka04-arch on the student-node.

```
k logs logger-complete-cka04-arch > /root/logger-complete-cka04-arch
```

3; There is a sample script located at /root/service-cka25-arch.sh on the student-node.
Update this script to add a command to filter/display the targetPort only for service service-cka25-arch using jsonpath. The service has been created under the default namespace on cluster1.

```
kubectl get svc service-cka25-arch -o jsonpath="{.spec.ports[].targetPort}"
9376

copy to the /root/service-cka25-arch.sh
```

4; It appears that the black-cka25-trb deployment in cluster1 isn't up to date. While listing the deployments, we are currently seeing 0 under the UP-TO-DATE section for this deployment. Troubleshoot, fix and make sure that this deployment is up to date.

```
k describe deploy black-cka25-trb

k get deploy
NAME              READY   UP-TO-DATE   AVAILABLE   AGE
black-cka25-trb   1/1     0            1           2m34s

k rollout resume deployment black-cka25-trb
deployment.apps/black-cka25-trb resumed

k get deploy
NAME              READY   UP-TO-DATE   AVAILABLE   AGE
black-cka25-trb   1/1     1            1           4m27s
```

5; A service account called deploy-cka19-trb is created in cluster1 along with a cluster role called deploy-cka19-trb-role. This role should have the permissions to get all the deployments under the default namespace. However, at the moment, it is not able to.

Find out what is wrong and correct it so that the deploy-cka19-trb service account is able to get deployments under default namespace.

```
k get sa nameSA
k describe sa nameSA
k get clusterrole nameCR
k describe clusterrole nameCR
k create rolebinding deploy-b --clusterrole=deploy-cka19-trb-role --serviceaccount=default:deploy-cka19-trb 
k auth can-i get deployments --as system:serviceaccount:default:deploy-cka19-trb
yes
```

6; For this question, please set the context to cluster1 by running:
kubectl config use-context cluster1

In the ckad-pod-design namespace, start a ckad-nginx-wiipwlznjy pod running the nginx:1.17 image; the container should be named nginx-custom-annotation.

Configure a custom annotation to that pod as below:

HOMEPAGE: <https://kodekloud.com/>

```
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: ckad-nginx-wiipwlznjy
  name: ckad-nginx-wiipwlznjy
  namespace: ckad-pod-design
  annotations: 
    HOMEPAGE: https://kodekloud.com/
spec:
  containers:
  - image: nginx:1.17
    name: nginx-custom-annotation
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

7; For this question, please set the context to cluster1 by running:

kubectl config use-context cluster1

In the ckad-multi-containers namespace, create a pod named tres-containers-pod, which has 3 containers matching the below requirements:

The first container named primero runs busybox:1.28 image and has ORDER=FIRST environment variable.

The second container named segundo runs nginx:1.17 image and is exposed at port 8080.

The last container named tercero runs busybox:1.31.1 image and has ORDER=THIRD environment variable.

NOTE: All pod containers should be in the running state.

```
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: primero
  name: tres-containers-pod
  namespace: ckad-multi-containers
spec:
  containers:
  - env:
    - name: ORDER
      value: FIRST
    image: busybox:1.28
    name: primero
    command:
    - /bin/sh
    - -c
    - sleep 3600;
    resources: {}
  - image: nginx:1.17
    name: segundo
    ports:
    - containerPort: 8080
    resources: {}
  - env:
    - name: ORDER
      value: THIRD
    image: busybox:1.31.1
    name: tercero
    command:
    - /bin/sh
    - -c
    - sleep 3600;
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

8; For this question, please set the context to cluster2 by running:

kubectl config use-context cluster2

On the cluster2-controlplane node, a Helm chart repository is given under the /opt/ path. It contains the files that describe a set of Kubernetes resources that can be deployed as a single unit. The files have some issues. Fix those issues and deploy them with the following specifications: -

1. The release name should be webapp-color-apd.

2. All the resources should be deployed on the frontend-apd namespace.
3. The service type should be node port.

4. Scale the deployment to 3.

5. Application version should be 1.20.0.

NOTE: - Remember to make necessary changes in the values.yaml and Chart.yaml files according to the specifications, and, to fix the issues, inspect the template files.

You can SSH into the cluster2 using ssh cluster2-controlplane command.

First, check the given namespace; if it doesn't exist, we must create it first; otherwise, it will give an error "namespaces not found" while installing the helm chart.
To check all the namespaces in the cluster2, we would have to run the following command:

```
kubectl get ns
kubectl create ns frontend-apd
```

Now, SSH to the cluster2-controlplane node and go to the /opt/ directory. We have given the helm chart directory webapp-color-apd that contains templates, values files, and the chart file etc.
Update the values according to the given specifications as follows: -

a.Update the value of the appVersion to 1.20.0 in the Chart.yaml file.

b.Update the value of the replicaCount to 3 in the values.yaml file.

c.  Update the value of the type to NodePort in the values.yaml file.

Now, we will use the helm lint command to check the Helm chart because it can identify errors such as missing or misconfigured values, invalid YAML syntax, and deprecated APIs etc.

```
cd /opt/

helm lint ./webapp-color-apd/
```

If there is no misconfiguration, we will see the similar output:

```
helm lint ./webapp-color-apd/
==> Linting ./webapp-color-apd/
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed
```

But in our case, there are some issues with the given templates.

Deployment apiVersion needs to be correctly written. It should be apiVersion: apps/v1.

In the service YAML, there is a typo in the template variable {{ .Values.service.name }} because of that, it's not able to reference the value of the name field defined in the values.yaml file for the Kubernetes service that is being created or updated.

Now run the following command to install the helm chart in the frontend-apd namespace:

```
helm install webapp-color-apd -n frontend-apd ./webapp-color-apd

helm ls -n frontend-apd
```

9; For this question, please set the context to cluster2 by running:

kubectl config use-context cluster2

A web application running on cluster2 called robox-west-apd on the fusion-apd-x1df5 namespace. The Ops team has created a new service account with a set of permissions for this web application. Update the newly created SA for this deployment.

Also, change the strategy type to Recreate, so it will delete all the pods immediately and update the newly created SA to all the pods.

In this task, we will use the kubectl command. Here are the steps:
Use the kubectl get command to list all the given resources

```
kubectl get po,deploy,sa,ns -n fusion-apd-x1df5
kubectl get deploy -n fusion-apd-x1df5 robox-west-apd -oyaml
```

Now, use the kubectl get command to retrieves the YAML definition of a deployment named robox-west-apd and save it into a file.

```
kubectl get deploy -n fusion-apd-x1df5 robox-west-apd -o yaml > <FILE-NAME>.yaml
```

open VI editor:

```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    global-kgh: robox-west-apd
  name: robox-west-apd
  namespace: fusion-apd-x1df5
spec:
  replicas: 3
  selector:
    matchLabels:
      global-kgh: robox-west-apd
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        global-kgh: robox-west-apd
    spec:
      containers:
      - image: nginx
        imagePullPolicy: Always
        name: robox-container
      serviceAccountName: galaxy-apd-xb12
```

Now, replace the resource with the following command:

```
kubectl replace -f <FILE-NAME>.yaml --force
```

The above command will delete the existing deployment and create a new one with changes in the given namespace

10; For this question, please set the context to cluster1 by running:

kubectl config use-context cluster1

In the dev-apd namespace, one of the developers has performed a rolling update and upgraded the application to a newer version. But somehow, application pods are not being created.

To regain the working state, rollback the application to the previous version.

After rolling the deployment back, on the controlplane node, save the image currently in use to the /root/records/rolling-back-record.txt file and increase the replica count to 4.

You can SSH into the cluster1 using ssh cluster1-controlplane command.

Run the following command to change the context: -

kubectl config use-context cluster1

In this task, we will use the kubectl describe, kubectl get, kubectl rollout and kubectl scale commands. Here are the steps: -

First check the status of the pods: -
kubectl get pods -n dev-apd

One of the pods is in an error state. By using the kubectl describe command. We can see that there is an issue with the image.

We can check the revision history of a deployment by using the kubectl history command as follows:

```
kubectl rollout history -n dev-apd deploy webapp-apd 
kubectl rollout history -n dev-apd deploy webapp-apd --revision=2
kubectl describe deploy -n dev-apd webapp-apd | grep -i image
On the Controlplane node, save the image name to the given path /root/records/rolling-back-record.txt:
```

11;

kubectl get rolebinding,clusterrolebinding --all-namespaces -o jsonpath='{range .items[?(@.subjects[0].name=="thor-cka24-trb")]}[{.roleRef.kind},{.roleRef.name}]{end}'
[Role,role-cka24-trb]

12; SECTION: ARCHITECTURE, INSTALL AND MAINTENANCE

kubectl config use-context cluster3

A pod called elastic-app-cka02-arch is running in the default namespace. The YAML file for this pod is available at /root/elastic-app-cka02-arch.yaml on the student-node. The single application container in this pod writes logs to the file /var/log/elastic-app.log.

One of our logging mechanisms needs to read these logs to send them to an upstream logging server but we don't want to increase the read overhead for our main application container so recreate this POD with an additional sidecar container that will run along with the application container and print to the STDOUT by running the command tail -f /var/log/elastic-app.log. You can use busybox image for this sidecar container.

```
apiVersion: v1
kind: Pod
metadata:
  name: elastic-app-cka02-arch
spec:
  containers:
  - name: elastic-ap
    image: busybox:1.28
    args:
    - /bin/sh
    - -c
    - >
      mkdir /var/log; 
      i=0;
      while true;
      do
        echo "$(date) INFO $i" >> /var/log/elastic-app.log;
        i=$((i+1));
        sleep 1;
      done
    volumeMounts:
    - name: varlog
      mountPath: /var/log
  - name: sidecar
    image: busybox:1.28
    args: [/bin/sh, -c, 'tail -f  /var/log/elastic-app.log']
    volumeMounts:
    - name: varlog
      mountPath: /var/log
  volumes:
  - name: varlog
    emptyDir: {}
```

```
kubectl replace -f /root/elastic-app-cka02-arch.yaml --force --context cluster3
pod "elastic-app-cka02-arch" deleted
pod/elastic-app-cka02-arch replaced
```

13; SECTION: ARCHITECTURE, INSTALL AND MAINTENANCE

kubectl config use-context cluster1

We have created a service account called green-sa-cka22-arch, a cluster role called green-role-cka22-arch and a cluster role binding called green-role-binding-cka22-arch.

Update the permissions of this service account so that it can only get all the namespaces in cluster1.

```
kubectl edit clusterrole green-role-cka22-arch --context cluster1
At the end add:

- apiGroups:
  - "*"
  resources:
  - namespaces
  verbs:
  - get 

  Verify 
  kubectl auth can-i get namespaces --as=system:serviceaccount:default:green-sa-cka22-arch
```

14; A pod called nginx-cka01-trb is running in the default namespace. There is a container called nginx-container running inside this pod that uses the image nginx:latest. There is another sidecar container called logs-container that runs in this pod.

For some reason, this pod is continuously crashing. Identify the issue and fix it. Make sure that the pod is in a running state and you are able to access the website using the curl <http://kodekloud-exam.app:30001> command on the controlplane node of cluster1.

```
kubectl logs -f nginx-cka01-trb -c nginx-container
kubectl edit pod nginx-cka01-trb -o yaml
kubectl get pod
kubectl logs -f nginx-cka01-trb -c nginx-container
# Still crashing

kubectl logs -f nginx-cka01-trb -c logs-container
You will see  
cat: can't open '/var/log/httpd/access.log': No such file or directory
cat: can't open '/var/log/httpd/error.log': No such file or directory

kubectl get pod nginx-cka01-trb -o yaml
```

Under containers: check the command: section, this is the command which is failing. If you notice its looking for the logs under /var/log/httpd/ directory but the mounted volume for logs is /var/log/nginx (under volumeMounts:). So we need to fix this path:

```
kubectl get pod nginx-cka01-trb -o yaml > /tmp/test.yaml
vi /tmp/test.yaml
Under command: change /var/log/httpd/access.log and /var/log/httpd/error.log to /var/log/nginx/access.log and /var/log/nginx/error.log respectively.

kubectl delete pod nginx-cka01-trb
kubectl apply -f /tmp/test.yaml
kubectl get pod

curl http://kodekloud-exam.app:30001
curl: (7) Failed to connect to kodekloud-exam.app port 30001: Connection refused
kubectl edit svc nginx-service-cka01-trb -o yaml 

Change app label under selector from httpd-app-cka01-trb to nginx-app-cka01-trb
```

15; A new service account called thor-cka24-trb has been created in cluster1. Using this service account, we are trying to list and get the pods and secrets deployed in default namespace. However, this service account is not able to perform these operations.

Look into the issue and apply the appropriate fix(es) so that the service account thor-cka24-trb can perform these operations.

```
kubectl get rolebinding -o yaml | grep -B 5 -A 5 thor-cka24-trb
# You will see role-cka24-trb is associated with this SA. So let's edit it to see the permissions
kubectl edit role role-cka24-trb

resources:
- pods
- secrets
verbs:
- list
- get
```

16; The green-deployment-cka15-trb deployment is having some issues since the corresponding POD is crashing and restarting multiple times continuously.
Investigate the issue and fix it, make sure the POD is in running state and its stable (i.e NO RESTARTS!).

```
kubectl get pod
kubectl logs -f green-deployment-cka15-trb-xxxx
kubectl delete pod green-deployment-cka15-trb-xxxx
kubectl get pod
# Pretty soon you will see the POD status has been changed to OOMKilled which confirms its the memory issue. So let's look into the resources that are assigned to this deployment.

kubectl get deploy
kubectl edit deploy green-deployment-cka15-trb

Under resources: -> limits: change memory from 256Mi to 512Mi and save the changes.
Now watch closely the POD status again
```

17; There is a pod called pink-pod-cka16-trb created in the default namespace in cluster4. This app runs on port tcp/5000 and it is exposed to end-users using an ingress resource called pink-ing-cka16-trb in such a way that it is supposed to be accessible using the command: curl <http://kodekloud-pink.app> on cluster4-controlplane host.

However, this is not working. Troubleshoot and fix this issue, making any necessary to the objects.

Note: You should be able to ssh into the cluster4-controlplane using ssh cluster4-controlplane command.

```
ssh cluster4-controlplane
curl kodekloud-pink.app
# You must be getting 503 Service Temporarily Unavailabl error.

kubectl edit svc pink-svc-cka16-trb
Under ports: change protocol: UDP to protocol: TCP
curl kodekloud-pink.app
# You must be getting curl: (6) Could not resolve host: example.com error, from the error we can see that its not able to resolve example.com host which indicated that it can be some issue related to the DNS. As we know CoreDNS is a DNS server that can serve as the Kubernetes cluster DNS, so it can be something related to CoreDNS.

Let's check if we have CoreDNS deployment running:
kubectl get deploy -n kube-system
# You will see that for coredns all relicas are down, you will see 0/0 ready pods. So let's scale up this deployment.

kubectl scale --replicas=2 deployment coredns -n kube-system
curl kodekloud-pink.app
```

18; The yello-cka20-trb pod is stuck in a Pending state. Fix this issue and get it to a running state. Recreate the pod if necessary.
Do not remove any of the existing taints that are set on the cluster nodes.

```
kubectl get pod --context=cluster2
kubectl get event --field-selector involvedObject.name=yello-cka20-trb --context=cluster2

# Error
Warning   FailedScheduling   pod/yello-cka20-trb   0/2 nodes are available: 1 node(s) had untolerated taint {node-role.kubernetes.io/master: }, 1 node(s) had untolerated taint {node: node01}. preemption: 0/2 nodes are available: 2 Preemption is not helpful for scheduling.

kubectl get pod yello-cka20-trb --context=cluster2 -o yaml
tolerations:
  - effect: NoSchedule
    key: node
    operator: Equal
    value: cluster2-node01

kubectl --context=cluster2 taint nodes cluster2-node01 node=cluster2-node01:NoSchedule --overwrite=true

kubectl get pod --context=cluster2
```

19; A manifest file is available at the /root/app-wl03/ on the student-node node. There are some issues with the file; hence couldn't deploy a pod on the cluster3-controlplane node.
After fixing the issues, deploy the pod, and it should be in a running state.
NOTE: - Ensure that the existing limits are unchanged.

```
cd /root/app-wl03/
kubectl create -f app-wl03.yaml 
# The Pod "app-wl03" is invalid: spec.containers[0].resources.requests: Invalid value: "1Gi": must be less than or equal to memory limit
 n the spec.containers.resources.requests.memory value is not configured as compare to the memory limit.

As a fix, open the manifest file with the text editor such as vim or nano and set the value to 100Mi or less than 100Mi.

resources:
     requests:
       memory: 100Mi
     limits:
       memory: 100Mi

kubectl create -f app-wl03.yaml 
pod/app-wl03 created
```

20; On cluster3, there is a web application pod running inside the default namespace. This pod which is part of a deployment called webapp-color-wl10 and makes use of an environment variable that can change constantly. Add this environment variable to a configmap and configure the pod in the deployment to make use of this config map.

Use the following specs-

1. Create a new configMap called webapp-wl10-config-map with the key and value as - APP_COLOR=red.

2. Update the deployment to make use of the newly created configMap name.

3. Delete and recreate the deployment if necessary.

```
kubectl get pods -n default
kubectl create configmap webapp-wl10-config-map --from-literal=APP_COLOR=red

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

21; A pod definition file is created at /root/peach-pod-cka05-str.yaml on the student-node. Update this manifest file to create a persistent volume claim called peach-pvc-cka05-str to claim a 100Mi of storage from peach-pv-cka05-str PV (this is already created). Use the access mode ReadWriteOnce.

Further add peach-pvc-cka05-str PVC to peach-pod-cka05-str POD and mount the volume at /var/www/html location. Ensure that the pod is running and the PV is bound.

```
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

kubectl apply -f /root/peach-pod-cka05-str.yaml
```

22; Create a pod with name tester-cka02-svcn in dev-cka02-svcn namespace with image registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3. Make sure to use command sleep 3600 with restart policy set to Always .

Once the tester-cka02-svcn pod is running, store the output of the command nslookup kubernetes.default from tester pod into the file /root/dns_output on student-node.

```
kubectl create ns dev-cka02-svcn

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

kubectl exec -n dev-cka02-svcn -i -t tester-cka02-svcn -- nslookup kubernetes.default
;; connection timed out; no servers could be reached

command terminated with exit code 1

kubectl scale deployment -n kube-system coredns --replicas=2

kubectl exec -n dev-cka02-svcn -i -t tester-cka02-svcn -- nslookup kubernetes.default >> /root/dns_output

student-node ~ ➜  cat /root/dns_output
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   kubernetes.default.svc.cluster.local
Address: 10.96.0.1
```

23; Part I:

Create a ClusterIP service .i.e. service-3421-svcn which should expose the pods namely pod-23 and pod-21 with port set to 8080 and targetport to 80.

Part II:

Store the pod names and their ip addresses from all namespaces at /root/pod_ips_cka05_svcn where the output is sorted by their IP's.
Please ensure the format as shown below:
POD_NAME        IP_ADDR
pod-1           ip-1
pod-3           ip-2
pod-2           ip-3

```
kubectl get pods --show-labels 
kubectl get pod -l mode=exam,type=external

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

kubectl get pods -A -o=custom-columns='POD_NAME:metadata.name,IP_ADDR:status.podIP' --sort-by=.status.podIP
```

24; Create a loadbalancer service with name wear-service-cka09-svcn to expose the deployment webapp-wear-cka09-svcn application in app-space namespace.

```
kubectl expose -n app-space deployment webapp-wear-cka09-svcn --type=LoadBalancer --name=wear-service-cka09-svcn --port=8080
service/wear-service-cka09-svcn exposed

k get svc -n app-space
NAME                      TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
wear-service-cka09-svcn   LoadBalancer   10.43.68.233   172.25.0.14   8080:32109/TCP   14s
```

25; Create a nginx pod called nginx-resolver-cka06-svcn using image nginx, expose it internally with a service called nginx-resolver-service-cka06-svcn.

Test that you are able to look up the service and pod names from within the cluster. Use the image: busybox:1.28 for dns lookup. Record results in /root/CKA/nginx.svc.cka06.svcn and /root/CKA/nginx.pod.cka06.svcn

```
kubectl run nginx-resolver-cka06-svcn --image=nginx 
kubectl expose pod/nginx-resolver-cka06-svcn --name=nginx-resolver-service-cka06-svcn --port=80 --target-port=80 --type=ClusterIP 

kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup nginx-resolver-service-cka06-svcn

kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup nginx-resolver-service-cka06-svcn > /root/CKA/nginx.svc.cka06.svcn

kubectl get pod nginx-resolver-cka06-svcn -o wide

IP=`kubectl get pod nginx-resolver-cka06-svcn -o wide --no-headers | awk '{print $6}' | tr '.' '-'`

kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup $IP.default.pod > /root/CKA/nginx.pod.cka06.svcn
```

26; We have created a service account called red-sa-cka23-arch, a cluster role called red-role-cka23-arch and a cluster role binding called red-role-binding-cka23-arch.

Identify the permissions of this service account and write down the answer in file /opt/red-sa-cka23-arch in format resource:pods|verbs:get,list on student-node

```
kubectl get rolebindings,clusterrolebindings \
> --all-namespaces  \
> -o custom-columns='KIND:kind,NAMESPACE:metadata.namespace,NAME:metadata.name,SERVICE_ACCOUNTS:subjects[?(@.kind=="ServiceAccount")].name'

k describe ClusterRole red-role-cka23-arch
Name:         red-role-cka23-arch
Labels:       <none>
Annotations:  <none>
PolicyRule:
  Resources         Non-Resource URLs  Resource Names  Verbs
  ---------         -----------------  --------------  -----
  deployments.apps  []                 []              [get list watch]

  echo "resource:deployments|verbs:get,list,watch" > /opt/red-sa-cka23-arch
```

27; Create a generic secret called db-user-pass-cka17-arch in the default namespace on cluster1 using the contents of the file /opt/db-user-pass on the student-node

```
k create secret generic db-user-pass-cka17-arch -n default --from-file=/opt/db-user-pass
secret/db-user-pass-cka17-arch created
```

28; A pod named beta-pod-cka01-arch has been created in the beta-cka01-arch namespace. Inspect the logs and save all logs starting with the string ERROR in file /root/beta-pod-cka01-arch_errors on the student-node.

```
k logs beta-pod-cka01-arch -n beta-cka01-arch | grep -i "error" > /root/beta-pod-cka01-arch_errors
```

29; Find the node across all clusters that consumes the most memory and store the result to the file /opt/high_memory_node in the following format cluster_name,node_name.

The node could be in any clusters that are currently configured on the student-node.

```
student-node ~ ➜  kubectl top node --context cluster1 --no-headers | sort -nr -k4 | head -1
cluster1-controlplane   124m   1%    768Mi   1%    

student-node ~ ➜  kubectl top node --context cluster2 --no-headers | sort -nr -k4 | head -1
cluster2-controlplane   79m   0%    873Mi   1%    

student-node ~ ➜  kubectl top node --context cluster3 --no-headers | sort -nr -k4 | head -1
cluster3-controlplane   78m   0%    902Mi   1%  

student-node ~ ➜  kubectl top node --context cluster4 --no-headers | sort -nr -k4 | head -1
cluster4-controlplane   78m   0%    901Mi   1%    

# Using this, find the node that uses most memory. In this case, it is cluster3-controlplane on cluster3.

echo cluster3,cluster3-controlplane > /opt/high_memory_node 
```

30; A pod called elastic-app-cka02-arch is running in the default namespace. The YAML file for this pod is available at /root/elastic-app-cka02-arch.yaml on the student-node. The single application container in this pod writes logs to the file /var/log/elastic-app.log.

One of our logging mechanisms needs to read these logs to send them to an upstream logging server but we don't want to increase the read overhead for our main application container so recreate this POD with an additional sidecar container that will run along with the application container and print to the STDOUT by running the command tail -f /var/log/elastic-app.log. You can use busybox image for this sidecar container.

```
apiVersion: v1
kind: Pod
metadata:
  name: elastic-app-cka02-arch
spec:
  containers:
  - name: elastic-app
    image: busybox:1.28
    args:
    - /bin/sh
    - -c
    - >
      mkdir /var/log; 
      i=0;
      while true;
      do
        echo "$(date) INFO $i" >> /var/log/elastic-app.log;
        i=$((i+1));
        sleep 1;
      done
    volumeMounts:
    - name: varlog
      mountPath: /var/log
  - name: sidecar
    image: busybox:1.28
    args: [/bin/sh, -c, 'tail -f  /var/log/elastic-app.log']
    volumeMounts:
    - name: varlog
      mountPath: /var/log
  volumes:
  - name: varlog

  kubectl replace -f /root/elastic-app-cka02-arch.yaml --force --context cluster3
pod "elastic-app-cka02-arch" deleted
```

31; There is some issue on the student-node preventing it from accessing the cluster3 Kubernetes Cluster.

Troubleshoot and fix this issue. Make sure that you are able to run the kubectl commands (For example: kubectl get node --context=cluster3) from the student-node.
The kubeconfig for all the clusters is stored in the default kubeconfig file: /root/.kube/config on the student-node.

```
vi /root/.kube/clusters/cluster3_config
server: https://cluster3-controlplane:64433
# Change server port:
server: https://cluster3-controlplane:6443
```

32; We deployed an app using a deployment called web-dp-cka06-trb. it's using the httpd:latest image. There is a corresponding service called web-service-cka06-trb that exposes this app on the node port 30005. However, the app is not accessible!

Troubleshoot and fix this issue. Make sure you are able to access the app using curl <http://kodekloud-exam.app:30005> command.

```
kubectl get deploy
#  You will notice that 0 out of 1 PODs are up, so let's look into the POD now.

kubectl get pod
# You will notice that web-dp-cka06-trb-xxx pod is in Pending state, so let's checkout the relevant events.

kubectl get event --field-selector involvedObject.name=web-dp-cka06-trb-xxx

Warning   FailedScheduling   pod/web-dp-cka06-trb-76b697c6df-h78x4   0/1 nodes are available: 1 persistentvolumeclaim "web-cka06-trb" not found. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling.

kubectl get pvc
# You should see web-pvc-cka06-trb in the output but as per logs the POD was looking for web-cka06-trb PVC. Let's update the deployment to fix this.

kubectl edit deploy web-dp-cka06-trb

Under volumes: -> name: web-str-cka06-trb -> persistentVolumeClaim: -> claimName change web-cka06-trb to web-pvc-cka06-trb and save the changes.

Look into the POD again to make sure its running now

kubectl get pod
kubectl edit deploy web-dp-cka06-trb
kubectl get pod
kubectl logs web-dp-cka06-trb-xxxx
kubectl get event --field-selector involvedObject.name=web-dp-cka06-trb-xxxx --sort-by='.lastTimestamp'

#Warning   FailedPostStartHook   pod/web-dp-cka06-trb-67dccb7487-2bjgf   Exec lifecycle hook ([/bin -c echo 'Test Page' > /usr/local/apache2/htdocs/index.html]) for Container "web-container" in Pod "web-dp-cka06-trb-67dccb7487-2bjgf_default(4dd6565e-7f1a-4407-b3d9-ca595e6d4e95)" failed - error: rpc error: code = Unknown desc = failed to exec in container: failed to start exec "c980799567c8176db5931daa2fd56de09e84977ecd527a1d1f723a862604bd7c": OCI runtime exec failed: exec failed: unable to start container process: exec: "/bin": permission denied: unknown, message: ""


kubectl edit deploy web-dp-cka06-trb
Under containers: -> lifecycle: -> postStart: -> exec: -> command: change /bin to /bin/sh
Look into the POD again to make sure its running now

kubectl get pod

# You will see error curl: (7) Failed to connect to kodekloud-exam.app port 30005: Connection refused

kubectl get deploy web-dp-cka06-trb -o yaml
kubectl edit svc web-service-cka06-trb

curl http://kodekloud-exam.app:30005
```

33; cluster4-node01 node that belongs to cluster4 seems to be in the NotReady state. Fix the issue and make sure this node is in Ready state.
Note: You can ssh into the node using ssh cluster4-node01

```
ssh cluster4-node01
systemctl status kubelet

systemctl start kubelet
systemctl status kubelet
journalctl -u kubelet --since "30 min ago" | grep 'Error:'
Check if /etc/kubernetes/pki/CA.crt file exists:

ls /etc/kubernetes/pki/
# You will notice that the file name is ca.crt instead of CA.crt so possibly kubelet is looking for a wrong file. Let's fix the config:

vi /var/lib/kubelet/config.yaml
# Change clientCAFile from /etc/kubernetes/pki/CA.crt to /etc/kubernetes/pki/ca.crt

systemctl start kubelet
vi /etc/kubernetes/kubelet.conf
server: https://cluster4-controlplane:6334
Change to
server: https://cluster4-controlplane:6443

systemctl restart kubelet
kubectl get node --context=cluster4
```

34; The cat-cka22-trb pod is stuck in Pending state. Look into the issue to fix the same. Make sure that the pod is in running state and its stable (i.e not restarting or crashing).
Note: Do not make any changes to the pod (No changes to pod config but you may destory and re-create).

```
kubectl get pod
kubectl --context cluster2 get event --field-selector involvedObject.name=cat-cka22-trb
Warning   FailedScheduling   pod/cat-cka22-trb   0/3 nodes are available: 1 node(s) had untolerated taint {node-role.kubernetes.io/master: }, 2 node(s) didn't match Pod's node affinity/selector. preemption: 0/2 nodes are available: 3 Preemption is not helpful for scheduling.

kubectl --context cluster2 get pod cat-cka22-trb -o yaml
Under affinity: you will see its looking for key: node and values: cluster2-node02 so let's verify if node01 has these labels applied.

kubectl --context cluster2 get node cluster2-node01 -o yaml
kubectl label node cluster1-node01 node=cluster2-node01

kubectl get node cluster2-node01 -o yaml
kubectl --context cluster2 get pod

kubectl --context cluster2 logs -f cat-cka22-trb
# The HOST variable seems incorrect, it must be set to kodekloud

kubectl --context cluster2 get pod -o yaml

kubectl --context cluster2 get secret
kubectl --context cluster2 get secret cat-cka22-trb -o yaml

echo "<the decoded value you see for hostname" | base64 -d
echo "kodekloud" | base64
kubectl edit secret cat-cka22-trb

hange requests storage hostname: a29kZWtsb3Vkdg== to hostname: a29kZWtsb3VkCg== (values may vary)
POD should be good now.
```

35; One of our Junior DevOps engineers have deployed a pod nginx-wl06 on the cluster3-controlplane node. However, while specifying the resource limits, instead of using Mebibyte as the unit, Gebibyte was used.
As a result, the node doesn't have sufficient resources to deploy this pod and it is stuck in a pending state
Fix the units and re-deploy the pod (Delete and recreate the pod if needed).

```
kubectl get pods -A
kubectl get pods -A | grep -i pending

kubectl describe po nginx-wl06
kubectl edit po nginx-wl06
Make use of the kubectl edit command to update the values from Gi to Mi:-

kubectl replace -f /tmp/kubectl-edit-xxxx.yaml --force
```

36; Find the pod that consumes the most memory and store the result to the file /opt/high_memory_pod in the following format cluster_name,namespace,pod_name.

The pod could be in any namespace in any of the clusters that are currently configured on the student-node.

```
kubectl top pods -A --context cluster1 --no-headers | sort -nr -k4 | head -1

kubectl top pods -A --context cluster2 --no-headers | sort -nr -k4 | head -1

kubectl top pods -A --context cluster3 --no-headers | sort -nr -k4 | head -1

kubectl top pods -A --context cluster4 --no-headers | sort -nr -k4 | head -1

echo cluster3,default,backend-cka06-arch > /opt/high_memory_pod
```

37; We deployed an app using a deployment called web-dp-cka06-trb. it's using the httpd:latest image. There is a corresponding service called web-service-cka06-trb that exposes this app on the node port 30005. However, the app is not accessible!

Troubleshoot and fix this issue. Make sure you are able to access the app using curl http://kodekloud-exam.app:30005 command.

```
kubectl get deploy

# You will notice that 0 out of 1 PODs are up, so let's look into the POD now.

kubectl get pod
k describe pod podName
kubectl get event --field-selector involvedObject.name=web-dp-cka06-trb-xxx

# Warning   FailedScheduling   pod/web-dp-cka06-trb-76b697c6df-h78x4   0/1 nodes are available: 1 persistentvolumeclaim "web-cka06-trb" not found. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling.

kubectl get pvc
You should see web-pvc-cka06-trb in the output but as per logs the POD was looking for web-cka06-trb PVC. Let's update the deployment to fix this.

kubectl edit deploy web-dp-cka06-trb

Under volumes: -> name: web-str-cka06-trb -> persistentVolumeClaim: -> claimName change web-cka06-trb to web-pvc-cka06-trb and save the changes.
Look into the POD again to make sure its running now

kubectl get pod

You will find that its still failing, most probably with ErrImagePull or ImagePullBackOff error. Now lets update the deployment again to make sure its using the correct image.

kubectl edit deploy web-dp-cka06-trb

Under spec: -> containers: -> change image from httpd:letest to httpd:latest and save the changes.
Look into the POD again to make sure its running now

kubectl get pod
# Crashing
kubectl logs web-dp-cka06-trb-xxxx
kubectl get event --field-selector involvedObject.name=web-dp-cka06-trb-xxxx --sort-by='.lastTimestamp'

Warning   FailedPostStartHook   pod/web-dp-cka06-trb-67dccb7487-2bjgf   Exec lifecycle hook ([/bin -c echo 'Test Page' > /usr/local/apache2/htdocs/index.html]) for Container "web-container" in Pod "web-dp-cka06-trb-67dccb7487-2bjgf_default(4dd6565e-7f1a-4407-b3d9-ca595e6d4e95)" failed - error: rpc error: code = Unknown desc = failed to exec in container: failed to start exec "c980799567c8176db5931daa2fd56de09e84977ecd527a1d1f723a862604bd7c": OCI runtime exec failed: exec failed: unable to start container process: exec: "/bin": permission denied: unknown, message: ""

kubectl edit deploy web-dp-cka06-trb

Under containers: -> lifecycle: -> postStart: -> exec: -> command: change /bin to /bin/sh
Look into the POD again to make sure its running now

kubectl get pod

curl http://kodekloud-exam.app:30005
You will see error curl: (7) Failed to connect to kodekloud-exam.app port 30005: Connection refused
Let's look into the service

kubectl edit svc web-service-cka06-trb
Let's verify if the selector labels and ports are correct as needed. You will note that service is using selector: -> app: web-cka06-trb
Now, let's verify the app labels:

kubectl get deploy web-dp-cka06-trb -o yaml
Under labels you will see labels: -> deploy: web-app-cka06-trb
So we can see that service is using wrong selector label, let's edit the service to fix the same

kubectl edit svc web-service-cka06-trb
curl http://kodekloud-exam.app:30005
```

38; There is a Cronjob called orange-cron-cka10-trb which is supposed to run every two minutes (i.e 13:02, 13:04, 13:06…14:02, 14:04…and so on). This cron targets the application running inside the orange-app-cka10-trb pod to make sure the app is accessible. The application has been exposed internally as a ClusterIP service.
However, this cron is not running as per the expected schedule and is not running as intended.
Make the appropriate changes so that the cronjob runs as per the required schedule and it passes the accessibility checks every-time

```
kubectl get cronjob

Make sure the schedule for orange-cron-cka10-trb cronjob is set to */2 * * * * if not then edit it.
Also before that look for the issues why this cron is failing

kubectl logs orange-cron-cka10-trb-xxxx
curl: (6) Could not resolve host: orange-app-cka10-trb

You will notice that the curl is trying to hit orange-app-cka10-trb directly but it is supposed to hit the relevant service which is orange-svc-cka10-trb so we need to fix the curl command.

Edit the cronjob

kubectl edit cronjob orange-cron-cka10-trb

Change schedule * * * * * to */2 * * * *
Change command curl orange-app-cka10-trb to curl orange-svc-cka10-trb
Wait for 2 minutes to run again this cron and it should complete now.
```

39; Find the pod that consumes the most CPU and store the result to the file /opt/high_cpu_pod in the following format cluster_name,namespace,pod_name.

The pod could be in any namespace in any of the clusters that are currently configured on the student-node.
```
kubectl top pods -A --context cluster1 --no-headers | sort -nr -k3 | head -1
kube-system   kube-apiserver-cluster1-controlplane            30m   258Mi   

kubectl top pods -A --context cluster2 --no-headers | sort -nr -k3 | head -1
kube-system   metrics-server-7cd5fcb6b7-fhdrl           5m    18Mi   

kubectl top pods -A --context cluster3 --no-headers | sort -nr -k3 | head -1
kube-system   metrics-server-7cd5fcb6b7-zvfrg           5m    18Mi   

kubectl top pods -A --context cluster4 --no-headers | sort -nr -k3 | head -1
kube-system   metrics-server-7cd5fcb6b7-zvfrg           5m    18Mi   

echo cluster1,kube-system,kube-apiserver-cluster1-controlplane > /opt/high_cpu_pod 
```

40; There is a pod called pink-pod-cka16-trb created in the default namespace in cluster4. This app runs on port tcp/5000 and it is exposed to end-users using an ingress resource called pink-ing-cka16-trb in such a way that it is supposed to be accessible using the command: curl http://kodekloud-pink.app on cluster4-controlplane host.

However, this is not working. Troubleshoot and fix this issue, making any necessary to the objects.

Note: You should be able to ssh into the cluster4-controlplane using ssh cluster4-controlplane command.

```
ssh cluster4-controlplane
curl kodekloud-pink.app

#You must be getting 503 Service Temporarily Unavailabl error.

kubectl edit svc pink-svc-cka16-trb
# Under ports: change protocol: UDP to protocol: TCP
Try to access the app again

curl kodekloud-pink.app
You must be getting curl: (6) Could not resolve host: example.com error, from the error we can see that its not able to resolve example.com host which indicated that it can be some issue related to the DNS. As we know CoreDNS is a DNS server that can serve as the Kubernetes cluster DNS, so it can be something related to CoreDNS.

Let's check if we have CoreDNS deployment running:
kubectl get deploy -n kube-system

kubectl scale --replicas=2 deployment coredns -n kube-system
Once CoreDBS is up let's try to access to app again.

curl kodekloud-pink.app
```

41; We recently deployed a DaemonSet called logs-cka26-trb under kube-system namespace in cluster2 for collecting logs from all the cluster nodes including the controlplane node. However, at this moment, the DaemonSet is not creating any pod on the controlplane node.
Troubleshoot the issue and fix it to make sure the pods are getting created on all nodes including the controlplane node.

```
kubectl --context2 cluster2 get ds logs-cka26-trb -n kube-system
# You will find that DESIRED CURRENT READY etc have value 2 which means there are two pods that have been created. You can check the same by listing the PODs

kubectl --context2 cluster2 get pod  -n kube-system
You can check on which nodes these are created on
kubectl --context2 cluster2 get pod <pod-name> -n kube-system -o wide

Under NODE you will find the node name, so we can see that its not scheduled on the controlplane node which is because it must be missing the reqiured tolerations. Let's edit the DaemonSet to fix the tolerations

kubectl --context2 cluster2 edit ds logs-cka26-trb -n kube-system

Under tolerations: add below given tolerations as well

- key: node-role.kubernetes.io/control-plane
  operator: Exists
  effect: NoSchedule
  ```

42; We have deployed a 2-tier web application on the cluster3 nodes in the canara-wl05 namespace. However, at the moment, the web app pod cannot establish a connection with the MySQL pod successfully.
You can check the status of the application from the terminal by running the curl command with the following syntax:
curl http://cluster3-controlplane:NODE-PORT

To make the application work, create a new secret called db-secret-wl05 with the following key values: -

1. DB_Host=mysql-svc-wl05
2. DB_User=root
3. DB_Password=password123

Next, configure the web application pod to load the new environment variables from the newly created secret.
Note: Check the web application again using the curl command, and the status of the application should be success.
You can SSH into the cluster3 using ssh cluster3-controlplane command.

```
kubectl get nodes -o wide

ssh cluster2-controlplane

curl http://10.17.63.11:31020
<!doctype html>
<title>Hello from Flask</title>
...

    <img src="/static/img/failed.png">
    <h3> Failed connecting to the MySQL database. </h3>


    <h2> Environment Variables: DB_Host=Not Set; DB_Database=Not Set; DB_User=Not Set; DB_Password=Not Set; 2003: Can&#39;t connect to MySQL server on &#39;localhost:3306&#39; (111 Connection refused) </>

kubectl create secret generic db-secret-wl05 -n canara-wl05 --from-literal=DB_Host=mysql-svc-wl05 --from-literal=DB_User=root --from-literal=DB_Password=password123

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

kubectl replace -f <FILE-NAME> --force

curl http://10.17.63.11:31020
```

43; John is setting up a two tier application stack that is supposed to be accessible using the service curlme-cka01-svcn. To test that the service is accessible, he is using a pod called curlpod-cka01-svcn. However, at the moment, he is unable to get any response from the application.
Troubleshoot and fix this issue so the application stack is accessible.
While you may delete and recreate the service curlme-cka01-svcn, please do not alter it in anyway.

```
kubectl exec curlpod-cka01-svcn -- curl curlme-cka01-svcn

The service has no endpoints configured. As we can delete the resource, let's delete the service and create the service again.

To delete the service, use the command kubectl delete svc curlme-cka01-svcn.
You can create the service using imperative way or declarative way.

Using imperative command:
kubectl expose pod curlme-cka01-svcn --port=80

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

  kubectl exec curlpod-cka01-svcn -- curl curlme-cka01-svcn
```

44; Create a nginx pod called nginx-resolver-cka06-svcn using image nginx, expose it internally with a service called nginx-resolver-service-cka06-svcn.
Test that you are able to look up the service and pod names from within the cluster. Use the image: busybox:1.28 for dns lookup. Record results in /root/CKA/nginx.svc.cka06.svcn and /root/CKA/nginx.pod.cka06.svcn

```
kubectl run nginx-resolver-cka06-svcn --image=nginx 
kubectl expose pod/nginx-resolver-cka06-svcn --name=nginx-resolver-service-cka06-svcn --port=80 --target-port=80 --type=ClusterIP 

To create a pod test-nslookup. Test that you are able to look up the service and pod names from within the cluster:

kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup nginx-resolver-service-cka06-svcn

kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup nginx-resolver-service-cka06-svcn > /root/CKA/nginx.svc.cka06.svcn

Get the IP of the nginx-resolver-cka06-svcn pod and replace the dots(.) with hyphon(-) which will be used below.

kubectl get pod nginx-resolver-cka06-svcn -o wide

IP=`kubectl get pod nginx-resolver-cka06-svcn -o wide --no-headers | awk '{print $6}' | tr '.' '-'`

kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup $IP.default.pod > /root/CKA/nginx.pod.cka06.svcn