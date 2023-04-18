# Task troubleshoot Broken Node

A Kubernetes worker node,named "worker" is in state NotReady .
Investigate why this is the case,and perform any appropriate steps to bring the node to a Ready state, ensuring that any changes are made permanent.

```
ssh worker
# sudo -i    # IF NOT ROOT

systemctl status kubelet
systemctl start kubelet
systemctl enable kubelet
```

