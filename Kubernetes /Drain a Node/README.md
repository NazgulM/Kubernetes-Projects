# Safely drain a Node, Create daemonsets, deployment and then drain a node

``
cat > daemonset.yaml << EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  creationTimestamp: null
  labels:
    app: mydaemonset
  name: mydaemonset
spec:
  selector:
    matchLabels:
      app: mydaemonset
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: mydaemonset
    spec:
      containers:
      - image: nginx
        name: nginx
        resources: {}

EOF

k create -f daemonset.yaml
daemonset.apps/mydaemonset created

create deployment

apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: mydeployment
  name: mydeployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mydeployment
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: mydeployment
    spec:
      containers:
      - image: nginx
        name: nginx
        resources: {}
status: {}

k create -f deploy.yaml
deployment.apps/mydeployment created

k get po -owide
k get node -owide
k drain worker --help
k drain worker --delete-emptydir-data --force --ignore-daemonsets
k get po -owide
k get node -owide

# After Maintenance

k uncordon worker
k get node -owide

# CLEANUP

k delete ds mydaemonset
k delete deploy mydeployment
```
