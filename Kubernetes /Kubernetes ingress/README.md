# Create Ingress Object

Create a new nginx Ingress resource as follows:
Name: "zinger"
Namespace: "zinger-ns"
Exposing service "hello" on path "/hello" using service port "8989"

```
kubectl create ns zinger-ns
namespace/zinger-ns created

k -n zinger-ns create ingress zinger --annotation nginx.ingress.kubernetes.io/rewrite-target="/" --rule="/hello*=hello:8989"
ingress.networking.k8s.io/zinger created
```

