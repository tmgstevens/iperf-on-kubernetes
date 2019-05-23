# iperf-on-kubernetes

Network Performance on Kubernetes with Iperf-3


## Topology

By default if "run-iperf.sh" is used:

1. A Iperf-Server is created as a Deployment
2. A Iperf-Client is created as a Daemonset. Each Client will be created on all the nodes including Masters and Iperf will be done for each host.

* Iperf Server and Client as Deployment and Daemonset

![](images/topo1.png)

* Iperf Server created as a Kubernetes Deployment

![](images/topo2.png)

* Iperf Clients created as a Kubernetes Daemonsets

![](images/topo3.png)

* Iperf Server - Service using Service Type: ClusterIP

![](images/topo4.png)



## Sample Execution of "run-iperf.sh" on a three node cluster (three masters tainted to be nodes)

* A Three node Kubernetes Cluster

```
# kubectl get nodes -o wide

NAME         STATUS   ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                                      KERNEL-VERSION               CONTAINER-RUNTIME
australia1   Ready    master   3d    v1.12.2   10.10.10.14   <none>        Red Hat Enterprise Linux Server 7.6 (Maipo)   3.10.0-957.10.1.el7.x86_64   docker://18.9.1
australia2   Ready    master   3d    v1.12.2   10.10.10.15   <none>        Red Hat Enterprise Linux Server 7.6 (Maipo)   3.10.0-957.10.1.el7.x86_64   docker://18.9.1
australia3   Ready    master   3d    v1.12.2   10.10.10.16   <none>        Red Hat Enterprise Linux Server 7.6 (Maipo)   3.10.0-957.10.1.el7.x86_64   docker://18.9.1
```

* Iperf Client, Server and Services on Cluster above

```
# kubectl get pods -o wide

NAME                                       READY   STATUS    RESTARTS   AGE   IP             NODE         NOMINATED NODE
iperf-clients-6c5z5                        1/1     Running   0          6s    192.168.2.19   australia2   <none>
iperf-clients-ks8pm                        1/1     Running   0          6s    192.168.0.21   australia1   <none>
iperf-clients-l9th6                        1/1     Running   0          6s    192.168.1.18   australia3   <none>
iperf-server-deployment-5984568b85-w2pg4   1/1     Running   0          6s    192.168.0.20   australia1   <none>
```

```
# kubectl get all -o wide

NAME                                           READY   STATUS    RESTARTS   AGE   IP             NODE         NOMINATED NODE
pod/iperf-clients-5jjnx                        1/1     Running   0          10s   192.168.0.22   australia1   <none>
pod/iperf-clients-fphs5                        1/1     Running   0          10s   192.168.2.20   australia2   <none>
pod/iperf-clients-mwjg4                        1/1     Running   0          10s   192.168.1.20   australia3   <none>
pod/iperf-server-deployment-5984568b85-2kw68   1/1     Running   0          10s   192.168.1.19   australia3   <none>

NAME                   TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE   SELECTOR
service/iperf-server   ClusterIP   10.103.23.6   <none>        5201/TCP   10s   app=iperf-server
service/kubernetes     ClusterIP   10.96.0.1     <none>        443/TCP    3d    <none>

NAME                           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE   CONTAINERS     IMAGES                         SELECTOR
daemonset.apps/iperf-clients   3         3         3       3            3           <none>          10s   iperf-client   gokulpch/iperf3-netperf:v1.0   app=iperf-client

NAME                                      DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS     IMAGES                         SELECTOR
deployment.apps/iperf-server-deployment   1         1         1            1           10s   iperf-server   gokulpch/iperf3-netperf:v1.0   app=iperf-server

NAME                                                 DESIRED   CURRENT   READY   AGE   CONTAINERS     IMAGES                         SELECTOR
replicaset.apps/iperf-server-deployment-5984568b85   1         1         1       10s   iperf-server   gokulpch/iperf3-netperf:v1.0   app=iperf-server,pod-template-hash=5984568b85
```

```
# kubectl get svc iperf-server -o yaml

apiVersion: v1
kind: Service
metadata:
  creationTimestamp: 2019-05-23T03:31:21Z
  name: iperf-server
  namespace: default
  resourceVersion: "457070"
  selfLink: /api/v1/namespaces/default/services/iperf-server
  uid: 3ba2be45-7d0b-11e9-8565-3cfdfed10ce0
spec:
  clusterIP: 10.103.22.228
  ports:
  - port: 5201
    protocol: TCP
    targetPort: server
  selector:
    app: iperf-server
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}
```

* Running Iperf

```
# ./iperf-on-kubernetes/run-iperf.sh

A Iperf Server is created as a Kubernetes Deployment and Iperf Client is created as a Daemonset
deployment.apps/iperf-server-deployment created
service/iperf-server created
daemonset.apps/iperf-clients created
Server is running

Waiting for iperf-clients-6c5z5 to start...
Client on 10.10.10.15:  Connecting to host iperf-server, port 5201
Client on 10.10.10.15:  [  4] local 192.168.2.19 port 34918 connected to 10.102.244.1 port 5201
Client on 10.10.10.15:  [ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
Client on 10.10.10.15:  [  4]   0.00-1.00   sec   423 MBytes  3.54 Gbits/sec   65    476 KBytes
Client on 10.10.10.15:  [  4]   1.00-2.00   sec   345 MBytes  2.90 Gbits/sec  415    686 KBytes
Client on 10.10.10.15:  [  4]   2.00-3.00   sec   444 MBytes  3.72 Gbits/sec  341    729 KBytes
Client on 10.10.10.15:  [  4]   3.00-4.00   sec   394 MBytes  3.30 Gbits/sec  1201    759 KBytes
Client on 10.10.10.15:  [  4]   4.00-5.00   sec   450 MBytes  3.77 Gbits/sec    0    759 KBytes
Client on 10.10.10.15:  [  4]   5.00-6.00   sec   412 MBytes  3.46 Gbits/sec    0    759 KBytes
Client on 10.10.10.15:  [  4]   6.00-7.00   sec   471 MBytes  3.95 Gbits/sec    0    759 KBytes
Client on 10.10.10.15:  [  4]   7.00-8.00   sec   491 MBytes  4.11 Gbits/sec    0    759 KBytes
Client on 10.10.10.15:  [  4]   8.00-9.00   sec   482 MBytes  4.05 Gbits/sec    0    759 KBytes
Client on 10.10.10.15:  [  4]   9.00-10.00  sec   466 MBytes  3.90 Gbits/sec    0    759 KBytes
Client on 10.10.10.15:  - - - - - - - - - - - - - - - - - - - - - - - - -
Client on 10.10.10.15:  [ ID] Interval           Transfer     Bandwidth       Retr
Client on 10.10.10.15:  [  4]   0.00-10.00  sec  4.28 GBytes  3.67 Gbits/sec  2022             sender
Client on 10.10.10.15:  [  4]   0.00-10.00  sec  4.28 GBytes  3.67 Gbits/sec                  receiver
Client on 10.10.10.15:
Client on 10.10.10.15:  iperf Done.

Client on 10.10.10.14:  Connecting to host iperf-server, port 5201
Client on 10.10.10.14:  [  4] local 192.168.0.21 port 35044 connected to 10.102.244.1 port 5201
Client on 10.10.10.14:  [ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
Client on 10.10.10.14:  [  4]   0.00-1.00   sec  2.46 GBytes  21.2 Gbits/sec   10    827 KBytes
Client on 10.10.10.14:  [  4]   1.00-2.00   sec  2.49 GBytes  21.4 Gbits/sec  417   2.17 MBytes
Client on 10.10.10.14:  [  4]   2.00-3.00   sec  2.37 GBytes  20.4 Gbits/sec    0   2.17 MBytes
Client on 10.10.10.14:  [  4]   3.00-4.00   sec  2.40 GBytes  20.6 Gbits/sec    0   2.17 MBytes
Client on 10.10.10.14:  [  4]   4.00-5.00   sec  2.38 GBytes  20.4 Gbits/sec    0   4.35 MBytes
Client on 10.10.10.14:  [  4]   5.00-6.00   sec  2.45 GBytes  21.1 Gbits/sec    0   4.35 MBytes
Client on 10.10.10.14:  [  4]   6.00-7.00   sec  2.41 GBytes  20.7 Gbits/sec    0   4.35 MBytes
Client on 10.10.10.14:  [  4]   7.00-8.00   sec  2.30 GBytes  19.8 Gbits/sec    0   4.35 MBytes
Client on 10.10.10.14:  [  4]   8.00-9.00   sec  2.42 GBytes  20.8 Gbits/sec    0   7.35 MBytes
Client on 10.10.10.14:  [  4]   9.00-10.00  sec  2.46 GBytes  21.1 Gbits/sec    0   7.35 MBytes
Client on 10.10.10.14:  - - - - - - - - - - - - - - - - - - - - - - - - -
Client on 10.10.10.14:  [ ID] Interval           Transfer     Bandwidth       Retr
Client on 10.10.10.14:  [  4]   0.00-10.00  sec  24.1 GBytes  20.7 Gbits/sec  427             sender
Client on 10.10.10.14:  [  4]   0.00-10.00  sec  24.1 GBytes  20.7 Gbits/sec                  receiver
Client on 10.10.10.14:
Client on 10.10.10.14:  iperf Done.

Client on 10.10.10.16:  Connecting to host iperf-server, port 5201
Client on 10.10.10.16:  [  4] local 192.168.1.18 port 59200 connected to 10.102.244.1 port 5201
Client on 10.10.10.16:  [ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
Client on 10.10.10.16:  [  4]   0.00-1.00   sec   436 MBytes  3.65 Gbits/sec   30    419 KBytes
Client on 10.10.10.16:  [  4]   1.00-2.00   sec   452 MBytes  3.79 Gbits/sec    2    507 KBytes
Client on 10.10.10.16:  [  4]   2.00-3.00   sec   410 MBytes  3.44 Gbits/sec    0    507 KBytes
Client on 10.10.10.16:  [  4]   3.00-4.00   sec   442 MBytes  3.71 Gbits/sec    0    507 KBytes
Client on 10.10.10.16:  [  4]   4.00-5.00   sec   456 MBytes  3.83 Gbits/sec    0    507 KBytes
Client on 10.10.10.16:  [  4]   5.00-6.00   sec   376 MBytes  3.15 Gbits/sec  320    624 KBytes
Client on 10.10.10.16:  [  4]   6.00-7.00   sec   425 MBytes  3.56 Gbits/sec    0    624 KBytes
Client on 10.10.10.16:  [  4]   7.00-8.00   sec   472 MBytes  3.96 Gbits/sec    0    624 KBytes
Client on 10.10.10.16:  [  4]   8.00-9.00   sec   478 MBytes  4.01 Gbits/sec    0    624 KBytes
Client on 10.10.10.16:  [  4]   9.00-10.00  sec   474 MBytes  3.97 Gbits/sec    0    624 KBytes
Client on 10.10.10.16:  - - - - - - - - - - - - - - - - - - - - - - - - -
Client on 10.10.10.16:  [ ID] Interval           Transfer     Bandwidth       Retr
Client on 10.10.10.16:  [  4]   0.00-10.00  sec  4.32 GBytes  3.71 Gbits/sec  352             sender
Client on 10.10.10.16:  [  4]   0.00-10.00  sec  4.32 GBytes  3.71 Gbits/sec                  receiver
Client on 10.10.10.16:
Client on 10.10.10.16:  iperf Done.

deployment.apps "iperf-server-deployment" deleted
service "iperf-server" deleted
daemonset.apps "iperf-clients" deleted
```


## Running Tests Manually

* Create Iperf Server Deployment
```
kubectl create -f kubernetes-manifests/iperf-server-deployment.yaml
```
* Create Iperf Server Service 
```
kubectl create -f kubernetes-manifests/iperf-server-service.yaml
```
* Create Iperf Client Daemonset 
```
kubectl create -f kubernetes-manifests/iperf-client-daemonset.yaml
```
* Run Iperf Tests from Iperf Client Pods
```
# kubectl get pods -l app=iperf-client -o name | cut -d'/' -f2

iperf-clients-24cw4
iperf-clients-h4hx6
iperf-clients-kgbc9

# Run Iperf with Kubectl

# kubectl exec iperf-clients-h4hx6 -- /bin/sh -c 'iperf3 -c iperf-server'

Connecting to host iperf-server, port 5201
[  4] local 192.168.1.22 port 37922 connected to 10.107.33.39 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-1.00   sec   391 MBytes  3.28 Gbits/sec  104    587 KBytes
[  4]   1.00-2.00   sec   337 MBytes  2.83 Gbits/sec  1194    821 KBytes
[  4]   2.00-3.00   sec   428 MBytes  3.58 Gbits/sec  192    645 KBytes
[  4]   3.00-4.00   sec   441 MBytes  3.71 Gbits/sec    0    645 KBytes
[  4]   4.00-5.00   sec   455 MBytes  3.81 Gbits/sec    0    645 KBytes
[  4]   5.00-6.00   sec   421 MBytes  3.53 Gbits/sec    0    645 KBytes
[  4]   6.00-7.00   sec   462 MBytes  3.88 Gbits/sec    0    645 KBytes
[  4]   7.00-8.00   sec   475 MBytes  3.99 Gbits/sec    0    645 KBytes
[  4]   8.00-9.00   sec   479 MBytes  4.01 Gbits/sec    0    645 KBytes
[  4]   9.00-10.00  sec   481 MBytes  4.05 Gbits/sec    0    645 KBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-10.00  sec  4.27 GBytes  3.67 Gbits/sec  1490             sender
[  4]   0.00-10.00  sec  4.27 GBytes  3.67 Gbits/sec                  receiver

iperf Done.
```

* Create Iperf Client as a Deployment 
```
kubectl create -f kubernetes-manifests/iperf-client-deployment.yaml
```

# Docker Usage

```
# docker run -it --rm -p 5201:5201 gokulpch/iperf3-netperf:v1.0 --help




Usage: iperf [-s|-c host] [options]
       iperf [-h|--help] [-v|--version]

Server or Client:
  -p, --port      #         server port to listen on/connect to
  -f, --format    [kmgKMG]  format to report: Kbits, Mbits, KBytes, MBytes
  -i, --interval  #         seconds between periodic bandwidth reports
  -F, --file name           xmit/recv the specified file
  -A, --affinity n/n,m      set CPU affinity
  -B, --bind      <host>    bind to a specific interface
  -V, --verbose             more detailed output
  -J, --json                output in JSON format
  -d, --debug               emit debugging output
  -v, --version             show version information and quit
  -h, --help                show this message and quit
Server specific:
  -s, --server              run in server mode
  -D, --daemon              run the server as a daemon
Client specific:
  -c, --client    <host>    run in client mode, connecting to <host>
  -u, --udp                 use UDP rather than TCP
  -b, --bandwidth #[KMG][/#] target bandwidth in bits/sec (0 for unlimited)
                            (default 1 Mbit/sec for UDP, unlimited for TCP)
                            (optional slash and packet count for burst mode)
  -t, --time      #         time in seconds to transmit for (default 10 secs)
  -n, --bytes     #[KMG]    number of bytes to transmit (instead of -t)
  -k, --blockcount #[KMG]   number of blocks (packets) to transmit (instead of -t or -n)
  -l, --len       #[KMG]    length of buffer to read or write
                            (default 128 KB for TCP, 8 KB for UDP)
  -P, --parallel  #         number of parallel client streams to run
  -R, --reverse             run in reverse mode (server sends, client receives)
  -w, --window    #[KMG]    TCP window size (socket buffer size)
  -C, --linux-congestion <algo>  set TCP congestion control algorithm (Linux only)
  -M, --set-mss   #         set TCP maximum segment size (MTU - 40 bytes)
  -N, --nodelay             set TCP no delay, disabling Nagle's Algorithm
  -4, --version4            only use IPv4
  -6, --version6            only use IPv6
  -S, --tos N               set the IP 'type of service'
  -L, --flowlabel N         set the IPv6 flow label (only supported on Linux)
  -Z, --zerocopy            use a 'zero copy' method of sending data
  -O, --omit N              omit the first n seconds
  -T, --title str           prefix every output line with this string
  --get-server-output       get results from server
  ```

## Intiating a Server with just Docker

```
* docker run  -it --rm --name=iperf-server -p 5201:5201 gokulpch/iperf3-netperf:v1.0 -s


-----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------
```


## Initiating a Client with just Docker

```
* docker inspect --format "{{ .NetworkSettings.IPAddress }}" iperf-server

172.17.0.2
```

```
* docker run  -it --rm gokulpch/iperf3-netperf:v1.0 -c 172.17.0.2

Connecting to host 172.17.0.2, port 5201
[  4] local 172.17.0.3 port 33590 connected to 172.17.0.2 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-1.00   sec  1.42 GBytes  12.2 Gbits/sec  689   1.10 MBytes
[  4]   1.00-2.00   sec  1.38 GBytes  11.9 Gbits/sec  213   1.10 MBytes
[  4]   2.00-3.00   sec  1.16 GBytes  9.97 Gbits/sec    0   1.10 MBytes
[  4]   3.00-4.00   sec  1.36 GBytes  11.7 Gbits/sec    0   1.10 MBytes
[  4]   4.00-5.00   sec  1.52 GBytes  13.1 Gbits/sec    0   1.10 MBytes
[  4]   5.00-6.00   sec  1.51 GBytes  12.9 Gbits/sec    0   1.10 MBytes
[  4]   6.00-7.00   sec  1.51 GBytes  13.0 Gbits/sec    1    789 KBytes
[  4]   7.00-8.00   sec  1.53 GBytes  13.1 Gbits/sec    0   1.10 MBytes
[  4]   8.00-9.00   sec  1.53 GBytes  13.1 Gbits/sec    0   1.10 MBytes
[  4]   9.00-10.00  sec  1.14 GBytes  9.78 Gbits/sec    0   1.10 MBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-10.00  sec  14.1 GBytes  12.1 Gbits/sec  903             sender
[  4]   0.00-10.00  sec  14.1 GBytes  12.1 Gbits/sec                  receiver

iperf Done.

```