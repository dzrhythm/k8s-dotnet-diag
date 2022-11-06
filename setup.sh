# Commands for setting up required resources in Azure running the demo.
# Consider running one command at a time to follow along.

# Update and set these variable values before continuing
resourceGroup=''
aksName=''
acrName='' # Must be unique amongst all Azure container registries
location='EastUS'

# Set these variables too
imageName='dotnet-diag-demo'
toolsImageName='dotnet-tools'

# Login to Azure
az login

# Create the resource group
az group create --name $resourceGroup --location $location

# Create and login to the ACR
az acr create --resource-group $resourceGroup --name $acrName --sku Basic
az acr login --name $acrName

# Build and push the application image
docker build --rm --pull -f Dockerfile -t $imageName .
docker tag $imageName $acrName.azurecr.io/$imageName
docker push $acrName.azurecr.io/$imageName

# Build and push dotnet tools image
docker build --rm --pull -f Dockerfile.dotnettools -t $toolsImageName .
docker tag $toolsImageName $acrName.azurecr.io/$toolsImageName
docker push $acrName.azurecr.io/$toolsImageName

# Create AKS cluster and get credentials
az aks create --resource-group $resourceGroup --name $aksName --node-count 2 --generate-ssh-keys --attach-acr $acrName
az aks get-credentials --resource-group $resourceGroup --name $aksName

# Before insalling the Helm chart, update the registry value in
# ./helm/dotnet-diag/values.yaml for your ACR.

# Install the Helm chart with just the application
helm install dotnet-diag ./helm/dotnet-diag

# Check the deployment
kubectl get pods,svc

# Upgrade the deployment with diagnostics enabled
helm upgrade dotnet-diag ./helm/dotnet-diag --set enableDiagnostics=true

# Check the deployment; notice there are now two containers in the pod.
kubectl get pods

##############################################################
# Now use the get-dotnet-dump.sh script to get a process dump.


##############################################################
## Cleanup Options
##

# Uninstall the Helm chart
helm uninstall dotnet-diag

# Delete or stop the cluster when done
az aks delete --resource-group $resourceGroup --name $aksName --yes --no-wait
az aks stop --resource-group $resourceGroup --name $aksName

# Restart the cluster
az aks start --name $aksName --resource-group $resourceGroup

# Delete the resource group and everything in it
az group delete --name $resourceGroup

