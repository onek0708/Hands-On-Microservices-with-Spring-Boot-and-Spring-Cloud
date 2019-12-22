minikube start --memory=10240 --cpus=4 --disk-size=30g --kubernetes-version=1.15.0 --vm-driver=virtualbox
minikube addons enable ingress
minikube addons metrics-server

#curl -o /dev/null -s -L -w "%{http_code}" http://kiali.istio-system.svc.cluster.local:20001/kiali/
#curl -o /dev/null -s -L -w "%{http_code}" http://grafana.istio-system.svc.cluster.local:3000
#curl -o /dev/null -s -L -w "%{http_code}" http://jaeger-query.istio-system.svc.cluster.local:16686
