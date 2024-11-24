eksctl create cluster \
  --name=efk-cluster \
  --region=us-east-1 \
  --node-type=t3.medium \
  --nodes=3 \
  --node-labels=name=node-efk \
  --node-volume-size=30

alias k=kubectl

k apply -f storageclass.yaml



kubectl create namespace efk
helm repo add elastic https://helm.elastic.co
helm search repo elastic


helm install elasticsearch \
 --set replicas=2 \
 --set service.type=LoadBalancer \
 --set volumeClaimTemplate.storageClassName=ebs-gp3 \
 --set volumeClaimTemplate.resources.requests.storage=5Gi \
 --set persistence.labels.enabled=true \
 --set persistence.labels.customLabel=elasticsearch-pv \
 elastic/elasticsearch -n efk

kubectl get secrets --namespace=efk elasticsearch-master-credentials -ojsonpath='{.data.username}' | base64 -d
kubectl get secrets --namespace=efk elasticsearch-master-credentials -ojsonpath='{.data.password}' | base64 -d

helm install kibana --set service.type=LoadBalancer elastic/kibana -n efk
kubectl get secrets --namespace=efk elasticsearch-master-credentials -ojsonpath='{.data.password}' | base64 -d
kubectl get secrets --namespace=efk kibana-kibana-es-token -ojsonpath='{.data.token}' | base64 -d

k apply -f event-generator.yaml

helm install fluent-bit fluent/fluent-bit -f fluentbit-values.yaml -n efk