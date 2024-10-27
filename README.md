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

![image](https://github.com/user-attachments/assets/cbd10d22-cdbc-48d4-ab8f-99ebc362e576)

```
helm install elasticsearch \
 --set replicas=2 \
 --set service.type=LoadBalancer \
 --set volumeClaimTemplate.storageClassName=ebs-gp3 \
 --set volumeClaimTemplate.resources.requests.storage=5Gi \
 --set persistence.labels.enabled=true \
 --set persistence.labels.customLabel=elasticsearch-pv \
 elastic/elasticsearch -n efk
```

![image](https://github.com/user-attachments/assets/9b8dabd3-130f-4809-9dfe-8716b508ac40)

![image](https://github.com/user-attachments/assets/6c23f4fe-ed07-4ba4-8269-29ecd119060d)

```
kubectl get secrets --namespace=efk elasticsearch-master-credentials -ojsonpath='{.data.username}' | base64 -d
kubectl get secrets --namespace=efk elasticsearch-master-credentials -ojsonpath='{.data.password}' | base64 -d
```

![image](https://github.com/user-attachments/assets/2d3d757a-c9c7-447c-b2fe-d9d733e0cdb6)

![image](https://github.com/user-attachments/assets/9d453a2f-f9f0-4cd2-a26a-4b305f159414)

![image](https://github.com/user-attachments/assets/a8dc2e5b-d6bd-4471-8614-15aa7eb4c240)

```
helm install kibana --set service.type=LoadBalancer elastic/kibana -n efk
kubectl get secrets --namespace=efk elasticsearch-master-credentials -ojsonpath='{.data.password}' | base64 -d
kubectl get secrets --namespace=efk kibana-kibana-es-token -ojsonpath='{.data.token}' | base64 -d

```
![image](https://github.com/user-attachments/assets/4714d44e-35a0-4532-ada1-f5f5870b4b39)

![image](https://github.com/user-attachments/assets/582a49c2-99f5-4433-80b2-f77114bad765)

![image](https://github.com/user-attachments/assets/d775383f-53c0-4ce2-9146-9f683647d1e7)

![image](https://github.com/user-attachments/assets/6599cb23-f235-4f08-88b8-3c09a519dbea)

![image](https://github.com/user-attachments/assets/5e575d6c-5913-4e3b-888c-10b81715ea0b)

![image](https://github.com/user-attachments/assets/480eb211-3382-4fb6-ab79-1b3ca98c14c6)

![image](https://github.com/user-attachments/assets/0f2f9551-c69c-445e-bf79-61bc24018281)

![image](https://github.com/user-attachments/assets/dc63df4f-93f3-4ee3-b509-b7d02eb66e7c)

To validate Kibana is able to connect to ElasticSearch (also UI might not open)

![image](https://github.com/user-attachments/assets/634664ff-9553-4c27-978e-1117c34f83cf)

![image](https://github.com/user-attachments/assets/23423c67-32d6-4eb8-899f-0d806ea400e2)


Deploy a log event generator

![image](https://github.com/user-attachments/assets/9dc839be-5ccd-4e43-afc2-9998cf2d94fe)

![image](https://github.com/user-attachments/assets/e35b8d09-3399-44a7-80b6-3295ced5a5fe)


```
helm repo add fluent https://fluent.github.io/helm-charts
helm show values fluent/fluent-bit > fluentbit-values.yaml
```

![image](https://github.com/user-attachments/assets/046991c5-5a06-4a2f-88cf-69cbb50cb1bd)

![image](https://github.com/user-attachments/assets/f0ae7298-54aa-460f-a5f2-293602ef4e9d)


```
helm install fluent-bit fluent/fluent-bit -f fluentbit-values.yaml -n efk
```

![image](https://github.com/user-attachments/assets/6e06a115-1d66-4e76-b149-2587d8e23d0f)

![image](https://github.com/user-attachments/assets/5cabcc02-5b3f-49cd-87a7-6d23463111b9)

![image](https://github.com/user-attachments/assets/f4fad6f0-3ac9-4cf9-a7bc-3ade423c2ed5)

![image](https://github.com/user-attachments/assets/c2352f72-82e0-465a-886f-8d7bcc3c6cdb)

![image](https://github.com/user-attachments/assets/3d9aeee2-d08b-4e93-b879-105b42390ed1)

![image](https://github.com/user-attachments/assets/a9c1406e-3f39-4f56-84c5-418c2c8f74c4)

![image](https://github.com/user-attachments/assets/c346bdc4-578e-43cf-966b-9df98bb6e57e)

![image](https://github.com/user-attachments/assets/3104c998-cf9b-4490-8018-eee862ffb4e8)

![image](https://github.com/user-attachments/assets/23dbd734-b95e-4695-b6c6-65f2c21d3219)

![image](https://github.com/user-attachments/assets/4f5c9d02-f772-4641-8030-cdc07dfcdffc)

![image](https://github.com/user-attachments/assets/d8f75c17-085d-4550-9bcb-3847457985c8)

![image](https://github.com/user-attachments/assets/a3002d99-5662-40ed-886e-f3f9057a5db8)

![image](https://github.com/user-attachments/assets/03940caa-819e-4b7e-a29c-d7b62b11594f)

![image](https://github.com/user-attachments/assets/9d2594a0-37ce-4a19-a08e-72921e7346a0)

![image](https://github.com/user-attachments/assets/3e695141-34e6-4c81-a902-761ac833ed1f)

![image](https://github.com/user-attachments/assets/5ad9e915-7f10-4433-a77f-13e3bb7756a4)

![image](https://github.com/user-attachments/assets/16e8816c-3947-4781-b5df-5fb2302cf231)

![image](https://github.com/user-attachments/assets/8857ecdb-f01d-4366-b853-832079d28b2d)

![image](https://github.com/user-attachments/assets/2d213119-68e9-4cb4-a1ca-62b5258eb373)

![image](https://github.com/user-attachments/assets/2b3bdaa3-dae2-430a-b70e-06b0c42ec243)

![image](https://github.com/user-attachments/assets/50469e4d-1a81-4544-9c11-e1d7eb573892)

![image](https://github.com/user-attachments/assets/54a8840e-f1b4-444e-8ebd-208c1304e7c6)

![image](https://github.com/user-attachments/assets/e26cb75d-200e-40bc-9a65-64aa01ab6114)

![image](https://github.com/user-attachments/assets/25cbd979-c9dd-45a7-93aa-51b3ee1134ac)

![image](https://github.com/user-attachments/assets/afa25e7a-1c26-4446-8c13-617b72a7048e)

![image](https://github.com/user-attachments/assets/e5f6b28f-1539-4771-afba-535aaccffd70)

![image](https://github.com/user-attachments/assets/0679207b-0503-4343-bc18-d4efa4ef4f6a)

## Deploying a Login App and Kibana on Kubernetes

![image](https://github.com/user-attachments/assets/4fbdd00f-0767-47c8-9bf7-00710cb7f134)

![image](https://github.com/user-attachments/assets/b691aee0-ea69-4942-8f00-7a305b5fed23)

![image](https://github.com/user-attachments/assets/5b90d94b-c4fa-4cb6-bff8-1d7f38875bef)

![image](https://github.com/user-attachments/assets/c7b1e079-8321-4f9b-84ce-8119f493100f)


```
helm upgrade fluent-bit fluent/fluent-bit -f fluentbit-values.yaml -n efk
```

![image](https://github.com/user-attachments/assets/707b3a03-2b2b-4ae9-af50-a3c2b336349d)

![image](https://github.com/user-attachments/assets/6e4efbfc-a509-4615-9c76-bede35fe9609)

![image](https://github.com/user-attachments/assets/5a427cc7-901c-478e-8b2e-985c343a0f11)

![image](https://github.com/user-attachments/assets/89546d4f-519a-4f9e-ba82-0ffc97a5d2bd)









































