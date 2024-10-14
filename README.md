# EFK-PROJECT


![image](https://github.com/user-attachments/assets/3f534e5a-14fa-47d7-9e73-37ecb2e073e6)

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



