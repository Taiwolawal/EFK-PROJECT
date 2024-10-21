eksctl create cluster \
  --name=efk-cluster \
  --region=us-east-1 \
  --node-type=t3.medium \
  --nodes=3 \
  --node-labels=name=node-efk \
  --node-volume-size=30

alias k=kubectl

k apply -f storageclass.yaml

export AWS_ACCESS_KEY_ID=<key> && export AWS_SECRET_ACCESS_KEY=<key>

kubectl create secret generic aws-secret \
--from-literal "key_id=${AWS_ACCESS_KEY_ID}" \
--from-literal "access_key=${AWS_SECRET_ACCESS_KEY}"


aws iam create-policy \
    --policy-name AmazonEKS_EBS_CSI_Driver_Policy \
    --policy-document file://ebs_csi_policy.json

aws iam attach-role-policy \
    --policy-arn arn:aws:iam::759623136685:policy/AmazonEKS_EBS_CSI_Driver_Policy \
    --role-name eksctl-efk-cluster-nodegroup-ng-06-NodeInstanceRole-yooZ0iP1N5Sw

helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver/
helm repo update
helm search repo aws-ebs-csi-driver
helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
    --namespace kube-system

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