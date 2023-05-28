# Kubernetes-Projects

Open Source container orchestration tool, originally developed by Google.
It helps manage containerized applications in different deployment  environments like on-prem, cloud.
Now since we have moved to microservices based architecture to deploy our applications that is small applications running them independently and then finally they are deployed in form of containers, so managing 1000 containers is difficult and hence kubernetes comes into picture.

Features of Kubernetes:

1. High Availability or no downtime for application.
2. Scalability or high performance: we can scale up or down based on the traffic.
3. Disaster recovery- backup and restore- application can restart with latest backup data.

Whenever you install kubernetes, you need to have 2 type if node- two type of server - master server or node or worker server or node. Can have few (two) master nodes and multiple worker nodes. these together make up - Kubernetes cluster (group of server) entirely.

Kubernetes - you will have multiple components, some components come installed on master nodes and some of them on worker node.

1. Kubelet - very first component by default installed on master and worker nodes.
It allows k8s cluster to communicate with each other and run the applications tasks on each node.
2. Api-server- deployed only on master node, all the master node will have api server- entry point for cluster. It will also run in form of containers. 
3. Controller- manager deployed on master node, controlling how many replicas are running, managing these many containers, how many containers up.Keep track of what is happening inside the cluster, if some cluster need to be restarted or if its down and need to be started. 
4. Scheduler- deployed on master node, ensures container placement, whenever a request for new container placement comes into picture it identity on which node it should schedule the container based on resource availability and usage. 
5. etcd: deployed on master node, having all the backup, information about kubernetes cluster, if kubernetes cluster down, you have to keep backup and take snapshot of etcd. Store the current state of k8s cluster, how many nodes and containers are running, also the k8s backup is actually configured from etcd snapshot.
6. you can have docker, containerd - you need to have install.
7. Virtual  network - allows master node to communicate with worker node
8. On worker nodes resource configuration should be high,



