#export PATH="$PATH:${HOME}/dev/ws/Hands-On-Microservices-with-Spring-Boot-and-Spring-Cloud/Chapter18/istio-1.2.4/bin"

#eval $(minikube docker-env)
#./gradlew build && docker-compose build
#kubectl create ns hands-on
#kubectl config set-context $(kubectl config current-context) --namespace=hands-on

for i in istio-1.2.4/install/kubernetes/helm/istio-init/files/crd*.yaml; do kubectl apply -f $i; done

kubectl apply -f istio-1.2.4/install/kubernetes/istio-demo.yaml

kubectl -n istio-system wait --timeout=600s --for=condition=available deployment --all


kubectl -n istio-system apply -f kubernetes/istio/setup/kiali-configmap.yml && \
    kubectl -n istio-system delete pod -l app=kiali && 
    kubectl -n istio-system wait --timeout=60s --for=condition=ready pod -l app=kiali

export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "$INGRESS_HOST minikube.me" | sudo tee -a /etc/hosts

curl -o /dev/null -s -L -w "%{http_code}" http://kiali.istio-system.svc.cluster.local:20001/kiali/
curl -o /dev/null -s -L -w "%{http_code}" http://grafana.istio-system.svc.cluster.local:3000
curl -o /dev/null -s -L -w "%{http_code}" http://jaeger-query.istio-system.svc.cluster.local:16686


curl -k http://product-composite.hands-on.svc.cluster.local:4004/actuator/health

mysql -umysql-user-dev -pmysql-pwd-dev review-db -e "select * from reviews" -h mysql.hands-on.svc.cluster.local

mongo --host mongodb.hands-on.svc.cluster.local -u mongodb-user-dev -p mongodb-pwd-dev --authenticationDatabase admin recommendation-db --eval "db.recommendations.find()"

open http://rabbitmq.hands-on.svc.cluster.local:15672 # rabbit-user-dev : rabbit-pwd-dev

kubectl get deployment auth-server product product-composite recommendation review -o yaml | istioctl kube-inject -f - | kubectl apply -f -

ACCESS_TOKEN=$(curl -k https://writer:secret@minikube.me/oauth/token -d grant_type=password -d username=magnus -d password=password -s | jq .access_token -r)

curl -ks https://minikube.me/product-composite/2 -H "Authorization: Bearer $ACCESS_TOKEN" | jq .productId

siege https://minikube.me/product-composite/2 -H "Authorization: Bearer $ACCESS_TOKEN" -c1 -d1

kubectl -n istio-system get deploy istio-ingressgateway -o json

#kubectl create -n istio-system secret tls istio-ingressgateway-certs --key kubernetes/cert/tls.key --cert kubernetes/cert/tls.crt
kubectl create -n istio-system secret tls istio-ingressgateway-certs --key ./tls.key --cert ./tls.crt

