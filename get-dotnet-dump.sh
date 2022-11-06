#!/bin/bash
## Commands to do a dotnet-dump on a pod.

# list pods to get our pod name
kubectl get pods

# Set the current pod name to get the dump from (update with yours)
pod=''

# set the name of our sidecar container
debugContainerName='diag'

# Get the process ID for dotnet using `dotnet-dump ps`
# Sample expected output:
#
# 6 dotnet     /usr/share/dotnet/dotnet
#
psOutput=$(kubectl exec $pod -c $debugContainerName -- /tools/dotnet-dump ps)
processId=$(echo $psOutput | sed 's/\s*\([0-9]*\).*/\1/')
echo $processId

# Execute dotnet-dump on the debug container in the pod
kubectl exec $pod -c $debugContainerName -- /tools/dotnet-dump collect -p $processId -o /tmp/dotnet.dmp

# Copy the dump file from the pod to local filesystem
kubectl -c $debugContainerName  cp "$pod:/tmp/dotnet.dmp" ./dotnet.dmp

# Delete the dump file from the pod
kubectl exec $pod -c $debugContainerName -- rm /tmp/dotnet.dmp
