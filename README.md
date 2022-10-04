# k8s-dotnet-diag

Demonstrates using .NET diagnostic tools from a conditionally enabled
sidecar container in pods deployed to Kubernetes. This approach allows
us to run our application more securely under normal circumstances
(read-only root file system, no additional tools insallled that increase
attack surface), and enabled diagnostics and tools when needed.

This repo contains:

- A [sample ASP.NET Core app](./aspnetapp) and accompanying [Dockerfile](./Dockerfile).
- [Dockerfile.dotnettools](./Dockerfile.dotnettools) for building a dotnet tools image to use as a sidecar.
- A [Helm](https://helm.sh) chart in the [helm](./helm/) directory.
- The [setup.sh](./setup.sh) script with the commands needed to set up the demo.
- The [get-dotnet-dump.sh](./get-dotnet-dump.sh) file with commands to run a `dotnet-dump` using the sidecar container.
