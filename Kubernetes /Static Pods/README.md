# Create Static Pods

Static Pods are managed directly by the kubelet daemon on a specific node, without the API server observing them. Unlike Pods that are managed by the control plane (for example, a Deployment); instead, the kubelet watches each static Pod (and restarts it if it fails).

Static Pods are always bound to one Kubelet on a specific node.
```
# Run this command on the node where kubelet is running
mkdir -p /etc/kubernetes/manifests/
cat <<EOF >/etc/kubernetes/manifests/static-web.yaml
apiVersion: v1
kind: Pod
metadata:
  name: static-web
  labels:
    role: myrole
spec:
  containers:
    - name: web
      image: nginx
      ports:
        - name: web
          containerPort: 80
          protocol: TCP
EOF

	
systemctl restart kubelet
	
# Run this command on the node where the kubelet is running
crictl ps

crictl ps
CONTAINER           IMAGE               CREATED             STATE               NAME                      ATTEMPT             POD ID              POD
92fbc8058ea03       6efc10a0510f1       21 minutes ago      Running             web                       1                   70666b2d7fe64       static-web-controlplane
```

If you try to use kubectl to delete the mirror Pod from the API server, the kubelet doesn't remove the static Pod:

```
k delete pod static-web-controlplane 
pod "static-web-controlplane" deleted

# You can see that the Pod is still running:
k get pods
NAME                      READY   STATUS    RESTARTS      AGE
static-web-controlplane   1/1     Running   1 (23m ago)   28s

Dynamic addition and removal of static pods
The running kubelet periodically scans the configured directory (/etc/kubernetes/manifests in our example) for changes and adds/removes Pods as files appear/disappear in this directory.

# This assumes you are using filesystem-hosted static Pod configuration
# Run these commands on the node where the container is running
#
mv /etc/kubernetes/manifests/static-web.yaml /tmp
sleep 20
crictl ps
# You see that no nginx container is running
mv /tmp/static-web.yaml  /etc/kubernetes/manifests/
sleep 20
crictl ps
```

