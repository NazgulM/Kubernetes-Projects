# Pod with the Highest CPU usage

View the Pod with the highest CPU usage
From the pod labeled  "tier=control-plane"
Find pod running highest CPU workloads and write the name of the pod consuming most CPU to the file

/tmp/high-cpu/pod-with-highest-cpu.txt (which already exists)

```
k top pod --sort-by cpu -l tier=control-plane -A
k top pod --sort-by cpu --selector tier=control-plane --all-namespaces

echo kube-apiserver-master > /tmp/high-cpu/pod-with-highest-cpu.txt
cat /tmp/high-cpu/pod-with-highest-cpu.txt
```
