# iperf-on-kubernetes

Network Performance on Kubernetes with Iperf-3


## Topology

By default if "run-iperf.sh" is used:

1. A Iperf-Server is created as a Deployment
2. A Iperf-Client is created as a Daemonset. Each Client will be created on all the nodes including Masters and Iperf will be done for each host.


## Sample Execution of "run-iperf.sh" on a three node cluster (three masters tainted to be nodes)

* A Three node Kubernetes Cluster

```
NAME             STATUS   ROLES    AGE    VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                   KERNEL-VERSION          CONTAINER-RUNTIME
maverick-kube1   Ready    master   166d   v1.12.2   172.29.86.57   <none>        Red Hat Enterprise Linux   3.10.0-693.el7.x86_64   docker://18.9.0
maverick-kube2   Ready    master   166d   v1.12.2   172.29.86.60   <none>        Red Hat Enterprise Linux   3.10.0-693.el7.x86_64   docker://18.9.0
maverick-kube3   Ready    master   145d   v1.12.2   172.29.86.14   <none>        Red Hat Enterprise Linux   3.10.0-693.el7.x86_64   docker://18.9.0
```
