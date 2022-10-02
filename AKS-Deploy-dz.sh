# Commands for running the demo in AKS.
# Update the variables for your environment.

resourceGroup="ais-dz-aks"
location="EastUS"
aksName="ais-dz-aks"
acrName="aisdzcr"
imageName="dotnet-diag-demo"
toolsImageName="dotnet-tools"

az login

# Createe the resource group
az group create --name $resourceGroup --location $location

# Create and login to the ACR
az acr create --resource-group $resourceGroup --name $acrName --sku Basic
az acr login --name $acrName

# Build and push the application image
docker build --rm --pull -f Dockerfile -t $imageName .
docker tag $imageName "$acrName.azurecr.io/$imageName"
docker push "$acrName.azurecr.io/$imageName"

# Build and push dotnet tools image
docker build --rm --pull -f Dockerfile.dotnettools -t "$toolsImageName" .
docker tag $toolsImageName "$acrName.azurecr.io/$toolsImageName"
docker push "$acrName.azurecr.io/$toolsImageName"

# Create AKS cluster and get credentials
az aks create --resource-group "$resourceGroup" --name "$aksName" --node-count 2 --generate-ssh-keys --attach-acr "$acrName"
az aks get-credentials --resource-group "$resourceGroup" --name "$aksName"

# Upgrade or install the Helm chart
helm upgrade dotnet-diag ./helm/dotnet-diag-cht --install

# Upgrade the deployment with diagnostics enabled
helm upgrade dotnet-diag ./helm/dotnet-diag-cht --set enableDiagnostics=true

# Check the deployment
kubectl get pods,svc

# Get a dotnet dump
pod=dotnet-diag-dotnet-diag-cht-855dbbfb54-78cfg

kubectl exec -it -c diag $pod -- bash

# Uninstall the Helm chart
helm uninstall dotnet-diag


# Stop or delete the cluster when done
az aks delete --name "$aksName" --resource-group "$resourceGroup" --yes --no-wait
az aks stop --name "$aksName" --resource-group "$resourceGroup"

# Restart the cluster
az aks start --name "$aksName" --resource-group "$resourceGroup"
