# Commands for setting up required resources in Azure and AKS
# Update the variables for your environment.


resourceGroup="ais-dz-aks"
location="EastUS"
aksName="ais-dz-aks"
acrName="aisdzcr"
imageName="dotnet-diag"

az login

# Resource Group
az group create --name $resourceGroup --location $location

# ACR
az acr create --resource-group $resourceGroup --name $acrName --sku Basic
az acr login --name $acrName

# Docker build
docker build --rm --pull -f Dockerfile -t $imageName .
#docker run -it --rm -v "C:\tmp:/scratch" $imageName
docker run -it --rm -P $imageName

# Tag and push the image to the ACR
docker tag $imageName "$acrName.azurecr.io/$imageName"
docker push "$acrName.azurecr.io/$imageName"

# dotnet tools image
toolsImageName=dotnet-tools
docker build --rm --pull -f Dockerfile.dotnettools -t "$toolsImageName" .
docker tag $toolsImageName "$acrName.azurecr.io/$toolsImageName"
docker push "$acrName.azurecr.io/$toolsImageName"

# dotnet-monitor image
monitorImageName=dotnet-dotnet-monitor
docker build --rm --pull -f Dockerfile.dotnetmonitor -t "$monitorImageName" .
docker tag $monitorImageName "$acrName.azurecr.io/$monitorImageName"
docker push "$acrName.azurecr.io/$monitorImageName"

# AKS
az aks create --resource-group "$resourceGroup" --name "$aksName" --node-count 2 --generate-ssh-keys --attach-acr "$acrName"
az aks get-credentials --resource-group "$resourceGroup" --name "$aksName"

# Create the deployment

kubectl apply -f dotnet-monitor-deploy.yaml
kubectl delete deploy dotnet-monitor-deploy

kubectl apply -f dotnet-tools-deploy.yaml
kubectl delete deploy dotnet-diag-deploy

kubectl get pods,svc
kubectl get services

# delete the cluster when done
az aks delete --name "$aksName" --resource-group "$resourceGroup" --yes --no-wait
az aks stop --name "$aksName" --resource-group "$resourceGroup"
az aks start --name "$aksName" --resource-group "$resourceGroup"


kubectl config get-contexts
kubectl config use-context docker-desktop