
kubectl delete -n istio-system secret tls istio-ingressgateway-certs 

kubectl delete configmap config-repo-auth-server       
kubectl delete configmap config-repo-gateway           
kubectl delete configmap config-repo-product-composite 
kubectl delete configmap config-repo-product           
kubectl delete configmap config-repo-recommendation    
kubectl delete configmap config-repo-review            

kubectl delete secret rabbitmq-server-credentials 
kubectl delete secret rabbitmq-credentials 
kubectl delete secret mongodb-server-credentials 
kubectl delete secret mongodb-credentials 
kubectl delete secret mysql-server-credentials 
kubectl delete secret mysql-credentials 
kubectl delete secret tls tls-certificate

# First deploy the resource managers and wait for their pods to become ready
kubectl delete -f kubernetes/services/overlays/dev/rabbitmq-dev.yml
kubectl delete -f kubernetes/services/overlays/dev/mongodb-dev.yml
kubectl delete -f kubernetes/services/overlays/dev/mysql-dev.yml

# Next deploy the microservices and wait for their pods to become ready
kubectl delete -k kubernetes/services/overlays/dev





