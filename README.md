# Create Insecure Cluster for e2e Testing

These commands should be run in Google Cloud Shell in the `ksoc-dev` project. They rely on the `gcloud` and `kubectl` command-line utilities to be installed which Cloud Shell already gives us.

## 1. Install Kops
Kops is used to bootstrap a cluster. It relies on a central configuration file that has likely already been created in our GCP project.

```
wget -O kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64 && \
chmod +x ./kops && \
sudo mv ./kops /usr/local/bin/
```

Ensure Kops is installed successfully:
```
kops version
```

## 2.Launch a Cluster
```
kops update cluster ksoc.insecure.k8s.local --yes --state gs://ksoc-insecure-dev/
```

The cluster should now be up and running. Go to `Compute Engine` -> `VM Instances` to view the cluster nodes. `kubectl` in your Cloud Shell session should also be configured automatically.

```
kubectl get pods --all-namespaces   
```

## 3. Delete the Cluster
```
kops delete cluster ksoc.insecure.k8s.local --yes
```

### IF NO STATE FILE EXISTS OR INSTALLING FROM SCRATCH DO THE FOLLOWING

This isn't necessary if the state file exists...you shouldn't have to do this.
```
PROJECT=`gcloud config get-value project` && \
export KOPS_FEATURE_FLAGS=AlphaAllowGCE && \
kops create cluster ksoc.insecure.k8s.local --zones us-west1-a --state gs://ksoc-insecure-dev/ --project=${PROJECT} --kubernetes-version=1.11.1 --node-count 1 && \
export KOPS_STATE_STORE=gs://ksoc-insecure-dev/
```


