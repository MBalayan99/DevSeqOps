PROJECT_ID="devsecops-454508"
IMAGE_NAME='nginx'
GAR_NAME='docker-repo'
REGION='us-central1'

gcloud auth configure-docker $REGION-docker.pkg.dev

docker pull nginx

docker tag $IMAGE_NAME $REGION-docker.pkg.dev/$PROJECT_ID/$GAR_NAME/$IMAGE_NAME:latest

docker push $REGION-docker.pkg.dev/$PROJECT_ID/$GAR_NAME/$IMAGE_NAME:latest