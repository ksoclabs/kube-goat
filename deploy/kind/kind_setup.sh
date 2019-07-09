if [ "$#" -eq 0 ]; then
   echo "Usage:  ./kind_setup.sh name"
   echo "   eg:  ./kind_setup.sh my-cluster"
   exit
fi

CLUSTER_NAME=$1

kind create cluster --name=${CLUSTER_NAME} --config=config.yaml

export KUBECONFIG="$(kind get kubeconfig-path --name="${CLUSTER_NAME}")"