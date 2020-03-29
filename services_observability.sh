# Services Observability with Prometheus, Grafana, Jaeger, and Kiali

# port forwarding to Prometheus
kubectl get pods -n istio-system -l prometheus -o jsonpath='{.items[0].metadata.name}'