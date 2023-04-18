# Safely Drain a Node

Set the node named node01 as unavailable and reschedule all the pods running on it

```
k get nodes
NAME           STATUS   ROLES           AGE     VERSION
controlplane   Ready    control-plane   6d15h   v1.26.1
node01         Ready    <none>          6d15h   v1.26.1

k get pods -n bob -owide
NAME                     READY   STATUS    RESTARTS   AGE     IP             NODE           NOMINATED NODE   READINESS GATES
alice-69cfb5bd87-78gfz   1/1     Running   0          100s    192.168.0.9    controlplane   <none>           <none>
alice-69cfb5bd87-lmfxb   1/1     Running   0          100s    192.168.1.7    node01         <none>           <none>
alice-69cfb5bd87-q8jrj   1/1     Running   0          100s    192.168.1.6    node01         <none>           <none>
alice-69cfb5bd87-r94k7   1/1     Running   0          2m22s   192.168.1.5    node01         <none>           <none>
alice-69cfb5bd87-rjbdw   1/1     Running   0          100s    192.168.0.8    controlplane   <none>           <none>
alice-69cfb5bd87-wkvnh   1/1     Running   0          100s    192.168.0.10   controlplane   <none>           <none>

k drain node01 --delete-emptydir-data --ignore-daemonsets --force
node/node01 cordoned
Warning: deleting Pods that declare no controller: default/high, default/pod2; ignoring DaemonSet-managed Pods: kube-system/canal-r92xx, kube-system/kube-proxy-ldwqn
evicting pod kube-system/coredns-68dc769db8-9h8gn
evicting pod bob/alice-69cfb5bd87-lmfxb
evicting pod bob/alice-69cfb5bd87-q8jrj
evicting pod bob/alice-69cfb5bd87-r94k7
evicting pod default/high
evicting pod default/pod2
pod/alice-69cfb5bd87-r94k7 evicted
pod/pod2 evicted
pod/alice-69cfb5bd87-lmfxb evicted
pod/alice-69cfb5bd87-q8jrj evicted
pod/high evicted
pod/coredns-68dc769db8-9h8gn evicted
node/node01 drained

k get nodes
NAME           STATUS                     ROLES           AGE     VERSION
controlplane   Ready                      control-plane   6d15h   v1.26.1
node01         Ready,SchedulingDisabled   <none>          6d15h   v1.26.1
```
