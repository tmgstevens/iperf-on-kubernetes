#!/usr/bin/env bash
set -eu

echo "A Iperf Server is created as a Kubernetes Deployment and Iperf Client is created as a Daemonset"

kubectl create -f iperf-all.yaml

until $(kubectl get pods -l app=iperf-server -o jsonpath='{.items[0].status.containerStatuses[0].ready}'); do
    echo "Waiting for iperf server to start..."
    sleep 5
done

echo "Server is running"
echo
