#!/bin/bash
myResourceGroup=$1
blobStorageAccount=$2
webapp=$3

##create group
az group create --name $myResourceGroup --location southcentralus

 ## create storage account
az storage account create --name $blobStorageAccount --location southcentralus --resource-group $myResourceGroup --sku Standard_LRS --kind blobstorage --access-tier hot

## create Blob storage containers
blobStorageAccountKey="$(az storage account keys list -g $myResourceGroup -n $blobStorageAccount --query [0].value --output tsv)"

az storage container create -n images --account-name $blobStorageAccount --account-key $blobStorageAccountKey --public-access off

az storage container create -n thumbnails --account-name $blobStorageAccount --account-key $blobStorageAccountKey --public-access container
 echo "Make a note of your Blob storage account key..."
echo $blobStorageAccountKey

##Create an App Service plan
az appservice plan create --name myAppServicePlan --resource-group $myResourceGroup  --number-of-workers 3 --sku Free

## create web app



az webapp create --name $webapp --resource-group $myResourceGroup --plan myAppServicePlan

## git repository connect

az webapp deployment source config --name $webapp --resource-group $myResourceGroup --branch master --manual-integration --repo-url https://github.com/rifatara92/revarure-p1


##Configure web app settings
az webapp config appsettings set --name $webapp --resource-group $myResourceGroup --settings AZURE_STORAGE_ACCOUNT_NAME=$blobStorageAccount AZURE_STORAGE_ACCOUNT_ACCESS_KEY=$blobStorageAccountKey

