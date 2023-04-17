# Create nslookup

```
N=frontendns
k create ns $N
k -n $N run frontendpod --image nginx
k -n $N get pod frontendpod --watch
k -n $N expose pod frontendpod --port 80 --name frontendsvc
k -n $N get all
k -n $N run dnsutils --image k8s.gcr.io/e2e-test-images/jessie-dnsutils:1.3 --command sleep 3600
k get svc
k -n $N exec -i -t dnsutils -- nslookup kubernetes.default
k -n $N exec -i -t dnsutils -- nslookup frontendsvc
k -n $N exec -i -t dnsutils -- nslookup frontendsvc.frontendns
 
N2=backendns
k create ns $N2
k -n $N2 run backendpod --image nginx
k -n $N2 get pod backendpod --watch
k -n $N2 expose pod backendpod --port 80 --name backendsvc
k -n $N2 get all
# BELOW WILL FAIL AS NAMESPACE IS MISSING
k -n $N exec -i -t dnsutils -- nslookup backendsvc
# BELOW WILL SUCCEED AS NAMESPACE IS PRESENT
k -n $N exec -i -t dnsutils -- nslookup backendsvc.backendns
 
# CLEANUP
N=frontendns
k -n $N delete pod,svc --all --force
k delete ns $N
N2=backendns
k -n $N2 delete pod,svc --all --force
k delete ns $N2
```

## Task2
Create a deployment as follows:
Name: nginx-deploy
Image: nginx
Expose this deployment via a service: nginx-service
Port: 80
Ensure that the service & pod are accessible 
via their respective DNS records

There is a yaml file available at for testing
/tmp/busybox.yaml
Use that yaml to create a pod and use the nslookup 
utility within that pod to look up the DNS records
of the service & pod and write the output to 
/tmp/service.dns
and 
/tmp/pod.dns
respectively.

