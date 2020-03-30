# Services Observability with Prometheus, Grafana, Jaeger, and Kiali

# port forwarding to Prometheus
kubectl port-forward -n istio-system \
$(kubectl get pods -n istio-system -l app=prometheus -o jsonpath='{.items[0].metadata.name}') 9090:9090
# this forward Cloud Shell port 9090 to Prometheus

# open Prometheus UI (Cloud Shell, Web Preview, change port: 9080, and Preview)
# create a new graph to show "Total Request sent to productpage". Enter the following line as Expression, and click Execute, Click Graph tab:
# istio_requests_total{destination_service="productpage.default.svc.cluster.local"}
# more Expression:
# rate(istio_requests_total{destination_service=~"productpage.*", response_code="200"}[5m])
# create a graph for the new metric:
# add Graph, add Expression:
# istio_double_request_count

# clean up Prometheus:
# Control-C stop Cloud Shell port forwarding
# remove the istio_double_request_count metric:
kubectl delete -f metrics.yaml


# port forwarding to Grafana
kubectl port-forward -n istio-system \
$(kubectl get pods -n istio-system -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000

# open Grafana UI  (Cloud Shell, Web Preview, change port: 3000, Change and Preview)
# Dashboard, Manage, istio, Istio Mesh Dashboard. Look around.
# Generate metrics data by sending traffic to application, from anather Cloud Shell ( + Add session):
# Get EXTERNAL_IP, and send traffic
export EXTERNAL_IP=$(kubectl get svc -n istio-system istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
for n in `seq 1 9`; do curl -s -o /dev/null http://$EXTERNAL_IP/productpage; done
# View Istio Services. On Istio Mesh Dashboard, check Global Request Volume, Global Success Rate, and the Services line appeared.
# View Istio Workloads(but first send traffic again). Check Incoming Request Volume, Incoming Success Rate, and others.

# Clean up Grafana: stop port forwarding.


# port forwarding to Jaeger
kubectl port-forward -n istio-system \
$(kubectl get pods -n istio-system -l app=jaeger -o jsonpath='{.items[0].metadata.name}') 20001:16686
# Get EXTERNAL_IP, and send traffic
export EXTERNAL_IP=$(kubectl get svc -n istio-system istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
for n in `seq 1 9`; do curl -s -o /dev/null http://$EXTERNAL_IP/productpage; done
# open Jaeger UI  (Cloud Shell, Web Preview, change port: 20001, Change and Preview)
# Review the traces. Find Traces: dropdown - productpage.default. Find Trace. Click spans to see detail.
# Generate metrics data by sending traffic to application, from anather Cloud Shell ( + Add session):


