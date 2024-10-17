eksctl create cluster \
  --name=efk-cluster \
  --region=us-east-1 \
  --node-type=t3.medium \
  --nodes=3 \
  --node-labels=name=node-efk \
  --node-volume-size=30


aws iam create-policy \
    --policy-name AmazonEKS_EBS_CSI_Driver_Policy \
    --policy-document file://ebs_csi_policy.json

aws iam attach-role-policy \
    --policy-arn arn:aws:iam::759623136685:policy/AmazonEKS_EBS_CSI_Driver_Policy \
    --role-name eksctl-efk-cluster-nodegroup-ng-a9-NodeInstanceRole-cGzpfeMbOJ6X

helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver/
helm repo update
