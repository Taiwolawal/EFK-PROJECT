# EFK-PROJECT


![image](https://github.com/user-attachments/assets/3f534e5a-14fa-47d7-9e73-37ecb2e073e6)

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateVolume",
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "ec2:DeleteVolume",
        "ec2:CreateSnapshot",
        "ec2:DeleteSnapshot",
        "ec2:DescribeVolumes",
        "ec2:DescribeSnapshots",
        "ec2:DescribeInstances",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeVolumeStatus",
        "ec2:DescribeVolumeAttribute",
        "ec2:DescribeSnapshotAttribute",
        "ec2:DescribeInstanceAttribute",
        "ec2:DescribeInstanceCreditSpecifications",
        "ec2:DescribeVolumeTypes",
        "ec2:DescribeVpcAttribute",
        "ec2:DescribeVpcEndpoints",
        "ec2:DescribeVpcs",
        "ec2:ModifyVolume",
        "ec2:ModifyVolumeAttribute",
        "ec2:ModifyInstanceAttribute"
      ],
      "Resource": "*"
    }
  ]
}
```

```
aws iam create-policy \
    --policy-name AmazonEKS_EBS_CSI_Driver_Policy \
    --policy-document file://ebs_csi_policy.json
```

![image](https://github.com/user-attachments/assets/b0dcd4e2-0b72-476b-9180-df272ecd3d53)



```
aws iam attach-role-policy \
    --policy-arn arn:aws:iam::759623136685:policy/AmazonEKS_EBS_CSI_Driver_Policy \
    --role-name eksctl-efk-cluster-nodegroup-ng-a9-NodeInstanceRole-cGzpfeMbOJ6X
```

```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-gp3
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
```

![image](https://github.com/user-attachments/assets/9dad9913-3707-4686-87e0-55e4ec19aefb)

```
export AWS_ACCESS_KEY_ID=<key> && export AWS_SECRET_ACCESS_KEY=<key>

kubectl create secret generic aws-secret \
--from-literal "key_id=${AWS_ACCESS_KEY_ID}" \
--from-literal "access_key=${AWS_SECRET_ACCESS_KEY}"
```

![image](https://github.com/user-attachments/assets/424920bf-1521-4c3b-8974-b22293e2fc30)

```
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver/
helm repo update
helm search repo aws-ebs-csi-driver
helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
    --namespace kube-system
```

![image](https://github.com/user-attachments/assets/06fe713d-2346-46bc-a9d1-41f5f916d734)

![image](https://github.com/user-attachments/assets/b449a164-e14a-4e8b-b494-34f0fcd4bca4)


```
kubectl create namespace efk
helm repo add elastic https://helm.elastic.co
helm search repo elastic
```

![image](https://github.com/user-attachments/assets/5a4a41e0-5fb4-4a05-822b-715e07924b5a)

![image](https://github.com/user-attachments/assets/cbd10d22-cdbc-48d4-ab8f-99ebc362e576)





















