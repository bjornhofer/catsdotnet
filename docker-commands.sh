registry_url = "myregistry.azurecr.io"
username = "myusername"
password = "mypassword"

# Tags
upload_frontend = "cat-service-frontend-upload"
upload_backend = "cat-service-backend-upload"
view_frontend = "cat-service-frontend-view"
view_backend = "cat-service-backend-view"

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
