# Scale the deployment

Scale the deployment named alice within namespace bob to 6 pods

```
k create ns bob
namespace/bob created

k create deployment alice -n bob --image nginx
deployment.apps/alice created

k get deploy -n bob
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
alice   1/1     1            1           9s

k scale deployment alice --replicas 6 -n bob
deployment.apps/alice scaled

k get deploy -n bob
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
alice   6/6     6            6           50s
```
