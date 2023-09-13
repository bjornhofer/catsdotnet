#!/bin/bash

# Description: This script builds and pushes the docker images to the Azure Container Registry
# Usage: ./docker-commands.sh <registry_url> <username> <password>

# Exit on any error
set -e

# Variables
# Check if the user has provided the registry url, username and password
if [ -z "$1" ]; then
    echo "Using default registry"
    registry_url="auvacatupload1234.azurecr.io"
else
    registry_url=$1
fi

if [ -z "$2" ]; then
    echo "Using default username"
    username=$(az acr credential show -n $registry_url --query "username" -o tsv)
else
    username=$2
fi

if [ -z "$3" ]; then
    echo "Using default password"
    password=$(az acr credential show -n $registry_url --query "passwords[0].value" -o tsv)
else
    password=$3
fi

# Build Tags for Docker Images
upload_frontend="cat-service-frontend-upload"
upload_backend="cat-service-backend-upload"
view_frontend="cat-service-frontend-view"
view_backend="cat-service-backend-view"

# Build Docker Images
# Upload Controller - Frontend
cd UploadController/frontend
docker build -t $upload_frontend .

# Upload Controller - Backend
cd ../backend
docker build -t $upload_backend .

# ViewController - Frontend
cd ../../ViewController/frontend
docker build -t $view_frontend .

# ViewController - Backend
cd ../backend
docker build -t $view_backend .

# Push Docker Images to Azure Container Registry
# Log in to your Azure Container Registry
docker login -u $username -p $password $registry_url

# Upload Controller - Frontend
docker tag $upload_frontend $registry_url/$upload_frontend
docker push $registry_url/$upload_frontend

# Upload Controller - Backend
docker tag $upload_backend $registry_url/$upload_backend
docker push $registry_url/$upload_backend

# ViewController - Frontend
docker tag $view_frontend $registry_url/$view_frontend
docker push $registry_url/$view_frontend

# ViewController - Backend
docker tag $view_backend $registry_url/$view_backend
docker push $registry_url/$view_backend
