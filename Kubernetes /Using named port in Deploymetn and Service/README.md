# Service

A Service in Kubernetes is an object (the same way that a Pod or a ConfigMap is an object). You can create, view or modify Service definitions using the Kubernetes API. Usually you use a tool such as kubectl to make those API calls for you.

```
N=namedport
k create ns $N

k -n $N create deployment named-port-deploy --image nginx --port 80 --dry-run=client -oyaml > named-port-deploy.yaml

# Add named port under the ports in one line with containerPort
# name: http-web-svc

vim named-port-deploy.yaml
k create -f named-port-deploy.yaml

k -n $N expose deployment named-port-deploy --port 8080 --target-port http-web-svc --type NodePort --dry-run=client -oyaml > named-port-svc.yaml

# Add under the ports section in one line with targetPort
# name: myserviceport
# nodePort: 31704

vim named-port-svc.yaml

k create -f named-port-svc.yaml

k -n $N get svc
AME                TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
named-port-deploy   NodePort   10.96.109.74   <none>        8080:31704/TCP   11s

# CURL USING NODEPORT - Service available on the nodes
curl 127.0.0.1:31704
!DOCTYPE html>
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

curl localhost:31704

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



# CURL USING CLUSTERIP
k -n $N get svc
curl 10.96.109.74:8080
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


# CLEANUP
N=namedport
k -n $N delete all --all
k -n $N delete ns $N