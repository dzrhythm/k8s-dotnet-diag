# Commands to do a dotnet-dump on a pod.
# First use the Azure CLI to authenticate to the cluster with:
# aks login
# az aks get-credentials -n "[cluster name]" -g "[resource group]" --admin

# *** update namespace and pod name first
$namespace = ""
$pod = ""

$debugContainerName = "debug"

# Get the process ID for dotnet using `dotnet-dump ps`
# Sample expected output:
#          6 dotnet     /usr/share/dotnet/dotnet
$psOutput = (kubectl -n $namespace exec -it $pod -c $debugContainerName -- /tools/dotnet-dump ps)
$s = ($psOutput | Select-String "\s\d+\s")
$processId = $s.Matches[0].Groups[0].Value.Trim()
if (!$processId) {
    throw "Unable to parse dotnet process id"
}

# Execute dotnet-dump on the debug container in the pod
kubectl -n $namespace exec -it $pod -c $debugContainerName -- /tools/dotnet-dump collect -p $processId -o /tmp/dotnet.dmp

# Copy the dump file from the pod to local filesystem
kubectl -n $namespace -c $debugContainerName  cp "$($pod):/tmp/dotnet.dmp" ./dotnet.dmp

# Delete the dump file from the pod
kubectl -n $namespace exec $pod -c $debugContainerName -- rm /tmp/dotnet.dmp