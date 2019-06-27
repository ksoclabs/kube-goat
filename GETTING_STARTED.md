# Getting Started

This document details the process of getting started with Kube-Goat in a local
environment.

## Table of Contents

<!-- vim-markdown-toc GFM -->

- [Kind](#kind)
  - [Prerequisites](#prerequisites)
  - [Install Kind](#install-kind)
  - [Create Cluster](#create-cluster)
  - [Delete Cluster](#delete-cluster)
  - [Customize Cluster](#customize-cluster)
    - [Example Configurations](#example-configurations)
- [Kops](#kops)
  - [Create Insecure Cluster for e2e Testing](#create-insecure-cluster-for-e2e-testing)
  - [1. Install Kops](#1-install-kops)
  - [2.Launch a Cluster](#2launch-a-cluster)
  - [3. Delete the Cluster](#3-delete-the-cluster)
    - [IF NO STATE FILE EXISTS OR INSTALLING FROM SCRATCH DO THE FOLLOWING](#if-no-state-file-exists-or-installing-from-scratch-do-the-following)

<!-- vim-markdown-toc -->

## Kind

`kind` (kubernetes-in-docker) can be used to bring up local clusters anywhere
you have Docker installed (e.g. Windows, MacOS, Linux) with the added benefit of
not having to deal with virtualization.

### Prerequisites

- Docker:
  - On Linux: `curl -fsSL https://get.docker.com`
  - On MacOS: `brew install docker`
- Kubectl:
  - On Linux:
    `curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl`
  - On MacOS: `brew install kubectl`
- [**Optional**] Go

### Install Kind

You can download & install pre-compiled versions of `kind` from their GitHub
[Releases](https://github.com/kubernetes-sigs/kind/releases).

Alternatively, you may build `kind` by running `go get -u -v sigs.k8s.io/kind`

### Create Cluster

1. `kind create cluster`
1. `export KUBECONFIG="$(kind get kubeconfig-path --name="kind""`

### Delete Cluster

1. `kind delete cluster`

### Customize Cluster

`kind` supports custom cluster configurations via its
[v1alphav3](https://godoc.org/sigs.k8s.io/kind/pkg/cluster/config/v1alpha3) API
group.

#### Example Configurations

To spin up a 3 control-plane + 3 worker node, create the following file, then
apply with `kind create cluster --name kind --config config.yaml`

```
kind: Cluster
apiVersion: kind.sigs.k8s.io/v1alpha3
nodes:
- role: control-plane
- role: control-plane
- role: control-plane
- role: worker
- role: worker
- role: worker
```

To use Calico CNI instead of `kind`'s default of Flannel, create the following
file, then apply accordingly:

```
kind: Cluster
apiVersion: kind.sigs.k8s.io/v1alpha3
nodes:
- role: control-plane
  extraMounts:
  - containerPath: /kind/manifests/default-cni.yaml
    hostPath: /path/to/custom-cni.yaml
    readOnly: true
    type: File
- role: control-plane
- role: worker
- role: worker
kubeadmConfigPatches:
- |
  apiVersion: kubeadm.k8s.io/v1beta1
  kind: ClusterConfiguration
  metadata:
    name: config
  networking:
    podSubnet: "192.168.0.0/16"
- |
  apiVersion: kubeproxy.config.k8s.io/v1alpha1
  kind: KubeProxyConfiguration
  metadata:
    name: config
  mode: "ipvs"
```

## KOPS on GCP


These commands should be run in Google Cloud Shell in the `ksoc-dev` project. They rely on the `gcloud` and `kubectl` command-line utilities to be installed which Cloud Shell already gives us.

## 1. Install Prerequisites

### KOPS
Kops is used to bootstrap a cluster. It relies on a central configuration file. First, install the `kops` binary:

```
wget -O kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64 && \
chmod +x ./kops && \
sudo mv ./kops /usr/local/bin/
```

Ensure Kops is installed successfully:
```
kops version
```

### GCloud SDK
Visit https://cloud.google.com/sdk/ for instructions on installing the gcloud CLI.
Once you are done installing GCloud SDK, you must run, gcloud init, this will configure your gcloud with your existing GCP project.

### kubectl
From the official Kubernetes kubectl release:
```
wget -O kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```

## 2.Launch a Cluster

In the `examples/kops` directory, `cd` into your cloud provider of choice and run the following command (this example is for GCP)"

Ensure you are authenticated to the GCP account for Kube-Goat
```
gcloud auth login
```

Run the following script to spin up Kube-Goat in GCP. Name the Project and Bucket as you wish.
```
./kops_gcp_setup.sh <GCP-Project-ID> <GCP-Bucket-ID>
```

This will go through the necessary steps to create a kube-goat cluster in your GCP account.

*This cluster runs using two Compute VMs and a single bucket for data storage. It is not free! You can always sign up with GCP to get $300 in credit for testing purposes*

The cluster should now be up and running. Go to `Compute Engine` -> `VM Instances` to view the cluster nodes. If you are wondering how you got your kubectl configured to the this cluster, KOPS does that for you. It exports a kubecfg file for a cluster from the state store to your ~/.kube/config 

```
kubectl get pods --all-namespaces
```

## 3. Delete the Cluster
Use `kops` to delete the running cluster:
```
kops delete cluster kube-goat.k8s.local --yes
```
Optionally, you can delete the entire GCP project:
```
gcloud projects delete <project_id> -q
```