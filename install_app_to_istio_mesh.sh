# This instruction are steps to install the sample app Bookinfo from Istio repo samples folder.
# requirement: Istio has been intalled and running in Google Kubernetes Engine. To install Istio into GKE, follow link:
# https://github.com/huangjinzhuo/observability/blob/master/install_istio_to_GKE.sh
# 

# Sign in to Google Cloud Platform Cloud Console with an account that has permission to manage the GKE and Istio
# GCP Cloud Console: https://console.cloud.google.com/
# select the project that has the GKE and Istio installed
# click on  >_  to activate Cloud Shell from Cloud Console. All commands below are run in Cloud Shell

# assign cluster name variable
export CLUSTER_NAME=dev-cluster

# get user account, project, and other env variables
export GCP_USER=$(gcloud config get-value account)
export GCP_PROJECT=$(gcloud config get-value core/project)
export CLUSTER_ZONE=$(gcloud container clusters list --format json | jq '.[] | select(.name=="'${CLUSTER_NAME}'") | .zone' | awk -F'"' '{print $2}')

# check if GKE cluster is running
gcloud container clusters list
kubectl get pods
# if you can't use kubectl, give yourself access to the cluster: 

# give user access to the cluster
gcloud container clusters get-credentials $CLUSTER_NAME \
--project $GCP_PROJECT \
--zone $CLUSTER_ZONE
kubectl create clusterrolebinding cluster-admin-binding \
--clusterrole cluster-admin \
--user $GCP_USER

# find application path. If not exist, download Istio, which also have sample apps in samples folder

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

# continuously check pods status until they are all Running/Succeeded
# POD_NO=${kubectl get pods -n istio-system -o jsonpath='{.status}' | wc -l }
:' Colon Apostrophe starts off a comment block that ends with another Apostrophe 

while true; do
    POD_STATUS=${kubectl get pods -n istio-system -o jsonpath='{.items[?(.status.phase != "Runninng" && .status.phase != "Succeeded")].status.phase}'}
    if $POD_STATUS!=[]
    then
        echo "Checking pod status..."
        ${kubectl get pods -n istio-system -o jsonpath='{.items[?(.status.phase != "Runninng" && .status.phase != "Succeeded")].metadata.name}: {.items[?(.status.phase != "Runninng" && .status.phase != "Succeeded")].status.phase}'}
    else
        exit
    fi
done

'
#### The above while loop logic works only when there is a single nexted condition. for example, remove this:      && .status.phase != "Succeeded"
#### This is a know issue of JSONPath: JsonPath nested condition and multiple conditions are not working #20352
#### https://github.com/kubernetes/kubernetes/issues/20352
#### A workaround is the while loop following:

all_running="false"
while [[ $all_running != true ]]; do
    POD_STATUS=($(kubectl get pods -n istio-system -o jsonpath='{.items[*].status.phase}'))
    all_running="true"
    for value in "${POD_STATUS[@]}"
    do
        echo $value
        if [[ $value != "Running" ]] && [[ $value != "Succeeded" ]]
        then
            echo "Checking pod status..."
            sleep 5
            # ${kubectl get pods -n istio-system -o jsonpath='{.items[?(.status.phase != "Runninng")].metadata.name}: {.items[?(.status.phase != "Runninng" )].status.phase}'}
            kubectl get pods -n istio-system -o jsonpath='{.items[?(.status.phase != "Runninng")].metadata.name}: {.items[?(.status.phase != "Runninng" )].status.phase}'
            all_running="false"
            break
        fi
    done
done

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

#So far the following barebone services has been installed: Istio, Propetheus, Jaeger, Kiali, Zipkin, Granfana.
# We can use port forwarding to forward get in those services web screen to check it out, but nothing to see.
# 
