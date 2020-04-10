#get user account
gcloud auth list
gcloud config get-value core/account
export GCP_USER=$(gcloud config get-value account)
printf "GCP_USER=$GCP_USER"

#get project
gcloud projects list    # list all projects
gcloud config get-value project
export GCP_PROJECT=$(gcloud config get-value core/project)
printf "GCP_PROJECT=$GCP_PROJECT"

export CLUSTER_NAME=dev-cluster
export CLUSTER_ZONE=us-central1-b
export CLUSTER_VERSION=latest
printf "CLUSTER_NAME=$CLUSTER_NAME"
printf "CLUSTER_ZONE=$CLUSTER_ZONE"
printf "CLUSTER_VERSION=$CLUSTER_VERSION"

# create the GKE cluster (in default VPC)
printf "Creating cluster $CLUSTER_NAME ..."
gcloud container clusters create $CLUSTER_NAME \
--zone $CLUSTER_ZONE \
--num-nodes 4 \
--machine-type n1-standard-2 \
--image-type 'COS' \
--scopes "gke-default", "compute-rw" \
--cluster-version $CLUSTER_VERSION \
--enable-autoscaling --min-nodes 4 --max-nodes 8 \
--enable-stackdriver-kubernetes \
--enable-basic-auth

gcloud container clusters list

# continuously check cluster status until it's RUNNING
while true; do
    if [[ "RUNNING" != $(gcloud container clusters list --format json | jq -r '.[] | select(.name=="'${CLUSTER_NAME}'") | .status') ]]
    then
        printf "Checking cluster status...\n"
        printf "$CLUSTER_NAME is: "
        gcloud container clusters list --format json | jq '.[] | select(.name=="'${CLUSTER_NAME}'") | .status'
        sleep 15
    else
        printf "$CLUSTER_NAME is: "
        gcloud container clusters list --format json | jq '.[] | select(.name=="'${CLUSTER_NAME}'") | .status'
        break
    fi
done

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
curl -L https://raw.githubusercontent.com/istio/istio/master/release/downloadIstioCandidate.sh | ISTIO_VERSION=$ISTIO_VERSION sh -
# above link is the raw file of https://github.com/istio/istio/blob/master/release/downloadIstioCandidate.sh 
# https://raw.githubusercontent.com/${repo}/${branch}/${path} <==> https://github.com/${repo}/blob/${branch}/${path}

# istioctl in bin/
cd istio-$ISTIO_VERSION
export PATH=$PATH:$PWD/bin

# create namespace and, using helm, install Istio Custom Resource Definiations (CRDs)
# check CRDs. 23 total, or more.
# install Istio with demo configuation
# (Istio on GKE add-on can be installed when creating a GKE cluster:
#     --addons=Istio --istio-config=auth=MTLS_STRICT
# with the above two options, Istio is installed.
# Istio open source version is installed with the following lines in this section)

kubectl create namespace istio-system

helm template install/kubernetes/helm/istio-init \
--name istio-init \
--namespace istio-system \
| kubectl apply -f -

kubectl get crds -n istio-system

helm template install/kubernetes/helm/istio \
--name istio \
--namespace istio-system \
--values install/kubernetes/helm/istio/values-istio-demo.yaml \
| kubectl apply -f -
# service installed:    istio-pilot, Mixer(istio-policy and istio-telemetry), istio-galley, istio-citadel, 
#                       istio-sidecar-injector, istio-ingressgateway, istio-egressgateway, and 
#                       prometheus, grafana, kiali, zipkin, tracing, jaeger-query, jaeger-agent, jaeger-collector, jaeger-collector-headless


kubectl get services -n istio-system
kubectl get pods --namespace istio-system

# continuously check pods status until they are all Running/Completed
$POD_STATUS=" "


# deploy the Bookinfo application
kubectl apply -f <(istioctl kube-inject -f samples/bookinfo/platform/kube/bookinfo.yaml)

kubectl get services
kubectl get pods

# check if Bookinfo app is running, by sending curl request from the  "ratings" container
# which is in  "ratings-v1-xxxx" pod,  to productpage in productpage pod
export RATINGS_POD=$(kubectl get pods -l app=ratings -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $RATINGS_POD -c ratings -- curl productpage:9080/productpage \
| grep -o "<title>.*</title>"
# only want to show title of the page

# open external access to the mesh, and get the external-ip
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
kubectl get gateway
kubectl get svc -n istio-system istio-ingressgateway
export EXTERNAL_IP=$(kubectl get svc -n istio-system istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl -I http://$EXTERNAL_IP/productpage
for n in `seq 1 9`; do curl -s -o /dev/null http://$EXTERNAL_IP/productpage; done

# use Stackdriver Monitoring: Dashboard - Kuberentes Engine (New). Check tabs: INFRASTRUCTURE, WORKLOADS, SERVICES

#clean up of the infrastructure
