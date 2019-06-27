if [ "$#" -eq 0 ]; then
   echo "Usage:  ./kops_gcp_setup.sh project-id state-store-id"
   echo "   eg:  ./kops_gcp_setup.sh hello-kubegoat hello-kubegoat-state-store"
   exit
fi

PROJECT_ID=$1
BUCKET_ID=$2

#update gcloud components
gcloud components update --quiet
gcloud components install beta

#bucket creation
kops_config="gs://${BUCKET_ID}"

#set kops environment variables
export KOPS_FEATURE_FLAGS=AlphaAllowGCE
export KOPS_STATE_STORE=${kops_config}

#create kube-goat project
gcloud projects create ${PROJECT_ID}
gcloud config set project ${PROJECT_ID}

#link billing to project
BILLING_ID=$(gcloud alpha billing accounts list --format json | jq -r '.[].name')
gcloud beta billing projects link ${PROJECT_ID} --billing-account=${BILLING_ID}
sleep 4

#enable compute api
gcloud services enable compute.googleapis.com
gcloud services enable containerregistry.googleapis.com

#create bucket for state store
echo $BUCKET_ID
gsutil mb -p $PROJECT_ID gs://${BUCKET_ID}

#substitute state store variable
deploy_template=$(cat kops_gcp_config.yaml | sed "s/{{PROJECT_ID}}/$PROJECT_ID/g")

#create cluster from manifest
echo "$deploy_template" | kops create -f -

#deploy resources
kops update cluster kube-goat.k8s.local --yes 

#update kubecfg
kops export kubecfg kube-goat.k8s.local

#validate the cluster
echo "Validating Cluster..."
while true; do 
  if kops --logtostderr=false validate cluster kube-goat.k8s.local -o json |  jq -r '.nodes[].status' | grep -q 'True' > /dev/null 2>&1; then
    break
  fi
done  

#launch k8s resources
docker build -t us.gcr.io/${PROJECT_ID}/redis:0.1 manifests/redis
docker push us.gcr.io/${PROJECT_ID}/redis:0.1

redis_template=$(cat manifests/redis/redis-pod.yaml | sed "s/{{PROJECT_ID}}/$PROJECT_ID/g")
echo "$redis_template" | kubectl create -f -

kubectl create -f manifests/app -f manifests/dashboard

