eval $(minikube docker-env)
./gradlew build && docker-compose build
kubectl create ns hands-on

kubectl config set-context $(kubectl config current-context) --namespace=hands-on

kubectl delete configmap config-repo-product 
kubectl delete secret rabbitmq-credentials rabbitmq-server-credentials tls-certificate 

kubectl create configmap config-repo-product --from-file=config-repo/application.yml --from-file=config-repo/product.yml --save-config

kubectl create secret generic rabbitmq-credentials \
    --from-literal=SPRING_RABBITMQ_USER_NAME=rabbit-user-dev \
    --from-literal=SPRING_RABBITMQ_PASSWORD=rabbit-pwd-dev \
    --save-config

kubectl create secret generic rabbitmq-server-credentials \
    --from-literal=SPRING_RABBITMQ_DEFAULT_USER=rabbit-user-dev \
    --from-literal=SPRING_RABBITMQ_DEFAULT_PASS=rabbit-pwd-dev \
    --save-config

sudo bach -c "echo $(minikube ip)    minikube.me | teel -a /etc/hosts"
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=minikube.me/O=minikube.me"
kubectl create secret tls tls-certificate --key ./tls.key --cert ./tls.crt

kubectl apply -k kubernetes/services/overlays/dev

ACCESS_TOKEN=$(curl -k https://writer:secret@minikube.me/oauth/token -d grant_type=password -d username=magnus -d password=password -s | jq .access_token -r)

curl -ks https://minikube.me/product-composite/2 -H "Authorization: Bearer $ACCESS_TOKEN" | jq .productId

kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v0.8.1/cert-manager.yaml

kubectl apply -f kubernetes/services/base/letsencrypt-issuer-staging.yaml
kubectl apply -f kubernetes/services/base/letsencrypt-issuer-prod.yaml

kubectl apply -f  kubernetes/services/base/ingress-edge-server-ngrok.yml

keytool -printcert -sslserver $NGROK_HOST:443 | grep -E "Owner:Issuer:"
