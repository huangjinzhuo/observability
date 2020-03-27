#get user account
gcloud auth list
gcloud config get-value core/user
export GCP_USER=$(gcloud config get-value user)

#get project
gcloud projects list    # list all projects
gcloud config get-value project
export GCP_PROJECT=$(gcloud config get-value core/project)

export CLUSTER_NAME=dev_cluster
export CLUSTER_ZONE=us-central1-b
export CLUSTER_VERSION=latest

# create the GKE cluster (in default VPC)
gcloud container clusters create $CLUSTER_NAME \
--zone $CLUSTER_ZONE \
--num-nodes 4 \
--machine-type n1-standard-2 \
--image-type COS \
--scopes gke-default, compute-rw \
--cluster-version $CLUSTER_VERSION \
--enable-autoscaling --min-nodes 4 --max-nodes 8 \
--enable-stackdriver-kubernetes \
--enable-basic-auth

gcloud container clusters list

# give user access to the cluster
gcloud container clusters get-credentials $CLUSTER_NAME \
--project $GCP_PROJECT \
--zone $CLUSTER_ZONE

kubectl create clusterrolebinding cluster-admin-binding \
--clusterrole cluster-admin \
--user $GCP_USER

# download Istio, which also have sample apps in samples folder
export APP_DIR=$HOME/bookinfo
export ISTIO_VERSION=1.5.0
mkdir $APP_DIR
cd $APP_DIR
curl -L https://git.io/getLatestIstio | ISTIO_VERSION=$ISTIO_VERSION sh -
# istioctl in bin/
cd istio-$ISTIO_VERSION
export PATH=$PATH:$PWD/bin

kubectl create namespace istio-system

# install Istio
kubectl apply -f 

