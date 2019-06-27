# GCP Setup
The following will require an active account on Google Cloud Platform (Free Tier)
https://cloud.google.com/free/

1. Ensure you are authenticated to the GCP account for Kube-Goat
```
gcloud auth login
```

2. Run the following script to spin up Kube-Goat in GCP. Name the Project and Bucket as you wish.
```
./kops_gcp_setup.sh <GCP-Project-ID> <GCP-Bucket-ID>
```

