# k8s-dotnet-diag

This repo demonstrates using [.NET diagnostic tools](https://learn.microsoft.com/dotnet/core/diagnostics/)
such as [dotnet-dump](https://learn.microsoft.com/dotnet/core/diagnostics/dotnet-dump)
from a conditionally enabled sidecar container in pods deployed to [Kubernetes](https://kubernetes.io/).
This approach allows us to:

- Run application more securely under normal circumstances
 (read-only root file system, no additional tools installed that increase attack surface), and
- Enable diagnostics and tools on demand when needed.

This repo contains:

- A [sample ASP.NET Core app](./aspnetapp) and accompanying [Dockerfile](./Dockerfile).
- A Dockerfile [Dockerfile.dotnettools](./Dockerfile.dotnettools) for building a dotnet tools image to use as a sidecar.
- A [Helm](https://helm.sh) chart in the [helm](./helm/) directory.
- The [setup.sh](./setup.sh) script with the commands needed to set up the demo.
- The [get-dotnet-dump.sh](./get-dotnet-dump.sh) file with commands to run a `dotnet-dump` using the sidecar container.
- A sample -[Dockerfile.builtin-dotnettools](Dockerfile.builtin-dotnettools) to show how to install
  the tools right in your application container if desired, using the .NET SDK in a stage.

## Prerequisites

- [.NET 6.0 SDK](https://dotnet.microsoft.com/download/dotnet/6.0)
- [Docker](https://www.docker.com/products/docker-desktop)
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli?view=azure-cli-latest)
- [Helm](https://helm.sh) 3 or later.
- A [Microsoft Azure account](https://azure.microsoft.com/free/).
- Recommended: [Visual Studio Code](https://code.visualstudio.com/)
  with the Docker and Kubernetes extensions.

## Running the Demo

To setup and run the demo, follow along the steps in the [setup.sh](./setup.sh) script.
This will walk through:

- Creating the ACR and AKS cluster in Azure.
- Building and pushing the container images.
- Deploying the application via Helm.
- Running a `dotnet-dump` to get a dump on our application container from a sidecar container.
