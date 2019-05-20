if [ "$#" -eq 0 ]; then
   echo "Usage:  ./kops_gcp_setup.sh  billing-account-id project-id state-store-id"
   echo "   eg:  ./kops_gcp_setup.sh  000112-9A2A8F-126DA hello-kubegoat hello-kubegoat-state-store"
   exit
fi

BILLING_ID=$1
PROJECT_ID=$2
BUCKET_ID=$3

#update gcloud components
gcloud components update --quiet
gcloud components install beta

#set kops environment variables
export KOPS_FEATURE_FLAGS=AlphaAllowGCE
export KOPS_STATE_STORE=gs://$BUCKET_ID

#create kube-goat project
gcloud projects create $PROJECT_ID
gcloud config set project $PROJECT_ID

#link billing to project
gcloud beta billing projects link $PROJECT_ID --billing-account=$BILLING_ID

#enable compute api
gcloud services enable compute.googleapis.com

#create bucket for state store
gsutil mb gs://$BUCKET_ID

#substitute state store variable
deploy_template=$(cat kops_gcp_config.yaml | sed "s/{{PROJECT_ID}}/$PROJECT_ID/g")

#create cluster from manifest
echo "$deploy_template" | kops create -f -

#deploy resources
kops update cluster kube-goat.k8s.local --yes

#update kubecfg
kops export kubecfg kube-goat.k8s.local

