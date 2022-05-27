# Commands for setting up required resources in Azure and AKS
# Update the variables for your environment.
# To run lines individually in a PowerShell integrated termainal
# in VS Code, place the cursor on the line and press F8.

resourceGroup=""
location="EastUS"
aksName=""
acrName=""
keyVaultName=""
imageName=""


az login

# Resource Group
az group create --name "$resourceGroup" --location "$location"

# ACR
az acr create --resource-group "$resourceGroup" --name "$acrName" --sku Basic
az acr login --name "$acrName"

# Docker build
docker build --rm --pull -f Dockerfile -t $imageName .
#docker run -it --rm -v "C:\tmp:/scratch" $imageName
docker run -it --rm  --privileged --cap-add SYS_PTRACE -P $imageName

# Tag and push the image to the ACR
docker tag $imageName "$acrName.azurecr.io/$imageName"
docker push "$acrName.azurecr.io/$imageName"

# dotnet-monitor image
docker build --rm --pull -f Dockerfile.dotnetmonitor -t "dotnet-monitor" .
docker tag dotnet-monitor "$acrName.azurecr.io/dotnet-monitor"
docker push "$acrName.azurecr.io/dotnet-monitor"

# AKS
az aks create --resource-group "$resourceGroup" --name "$aksName" --node-count 2 --generate-ssh-keys --attach-acr "$acrName"
az aks get-credentials --resource-group "$resourceGroup" --name "$aksName"

# Create the deployment
kubectl apply -f k8s-aspnetapp-all-in-one-dz.yaml

kubectl delete deploy aks-dotnetdumptest

kubectl apply -f dotnet-monitor-deploy.yaml
kubectl delete deploy deploy-exampleapp

kubectl get pods,svc
kubectl get services

# delete the cluster when done
az aks delete --name "$aksName" --resource-group "$resourceGroup" --yes --no-wait
az aks stop --name "$aksName" --resource-group "$resourceGroup"
az aks start --name "$aksName" --resource-group "$resourceGroup"


kubectl config get-contexts
kubectl config use-context docker-desktop