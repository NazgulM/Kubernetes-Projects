# Nodes ready or not

Calculate how many nodes are ready
(not including nodes tainted with NoSchedule )
and write the number to /tmp/health-nodes.txt

Taints: node-role.kubernetes.io/control-plane:NoSchedule
        node-role.kubernetes.io/master:NoSchedule

```
k get nodes
NAME           STATUS   ROLES           AGE     VERSION
controlplane   Ready    control-plane   6d15h   v1.26.1
node01         Ready    <none>          6d15h   v1.26.1

k describe nodes master | vi -
k edit node controlplane
node/controlplane edited

k describe nodes worker | vi -

echo 2 > /tmp/health-nodes.txt

k describe nodes | grep -i taint | grep -i -v noschedule | wc -l
2

cat /tmp/health-nodes.txt 
2
```
