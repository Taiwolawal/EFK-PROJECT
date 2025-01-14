# EFK-PROJECT

This project is focused on setting up and using the powerful EFK stack to monitor and manage our applications.

The EFK stack is a popular logging and monitoring solution that efficiently collects, analyzes, and visualizes logs from your applications and infrastructure. Their purposes are:

- Elasticsearch: Store and search your logs efficiently.
- Fluent Bit: Collect and forward your logs from various sources.
- Kibana: Visualize and explore your logs to gain valuable insights.

The way it works is Fluentbit reads the logs from the application container log files present on the nodes and pushes these logs to Elasticsearch which handles storing and searching of logs efficiently. Then Kibana will be used as a visualization tool (UI) for checking those logs.

There are numerous log management tools such as Logstash, Fluentd, etc. I will prefer Fluenbit for this project because it boasts impressive lightweight performance. In the screenshot below are major differences.

![image](https://github.com/user-attachments/assets/c0cc68b7-d0e9-4f42-9738-8b62ad06b7cb)

Requirements for the project:
- A Kubernetes Cluster
- Helm
  
Provision your Kubernetes cluster using eksctl command.

![image](https://github.com/user-attachments/assets/531aeb17-1603-4419-8736-45bedea743da)

To deploy Elasticsearch in an Amazon EKS cluster effectively, certain prerequisites must be in place. Elasticsearch, functioning as a database, is typically deployed as a stateful set, which requires the use of Persistent Volume Claims (PVCs). These PVCs must be backed by storage resources to ensure reliable and persistent data storage.

To provision Elastic Block Store (EBS) volumes for these PVCs within the EKS cluster, the following components are essential:

-  StorageClass: A storage class configured with the AWS EBS provisioner is required. This storage class defines the parameters for provisioning EBS volumes, such as volume type, size, and access modes.
-  AWS EBS CSI Driver: The EBS Container Storage Interface (CSI) driver must be installed and configured within the EKS cluster. This driver allows Kubernetes to communicate with AWS and dynamically provision EBS volumes as requested by PVCs.

AWS EBS in EKS setup procedure:
- Create the required IAM role for the EBS CSI Driver.
- Install the EBS CSI Driver using EKS Addons.

Create the OIDC Provider for the EKS cluster

```
eksctl utils associate-iam-oidc-provider \
  --region <region> \
  --cluster <cluster-name> \
  --approve
```
Confirm the cluster’s OIDC provider ``` aws eks describe-cluster --name my-cluster --query "cluster.identity.oidc.issuer" --output text ```

![image](https://github.com/user-attachments/assets/441a72af-1179-49c3-995c-5ad3592a6cdc)

Create IAM role for Service Account: create an IAM role which can be assumed by Kubernetes Service Accounts, the authorized principal should be the Kubernetes OIDC provider, and to allow only a specific service account, we can use policy conditions to restrict access for selected ones.

Create the IAM role, granting the AssumeRoleWithWebIdentity action. Update the json file with ```account-id```, ```region``` the last digit from the OIDC ```96EB298B212A248710459183292D0B25```.

aws-ebs-csi-driver-trust-policy.json

![image](https://github.com/user-attachments/assets/b18fb40f-58a8-415a-941c-222ed803cfd7)

Create the role.

```
aws iam create-role \
      --role-name AmazonEKS_EBS_CSI_DriverRole \
      --assume-role-policy-document file://"aws-ebs-csi-driver-trust-policy.json"

```

![image](https://github.com/user-attachments/assets/316c2d34-08b7-476d-8da3-b1b1154b6631)


Attach the AWS managed policy to the role 

```
aws iam attach-role-policy \
      --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
      --role-name AmazonEKS_EBS_CSI_DriverRole
```




It is recommended to install the Amazon EBS CSI driver through the Amazon EKS add-on to improve security and reduce the amount of work

```
aws eks create-addon \
  --cluster-name efk-cluster \
  --addon-name aws-ebs-csi-driver \
  --addon-version v1.37.0-eksbuild.1 \
```

![image](https://github.com/user-attachments/assets/9b4227d1-7793-415a-81dd-71f5fc39e09d)

![image](https://github.com/user-attachments/assets/80015eb8-0838-4595-813f-c37b84d592fc)

Create a Storage Class for Elasticsearch

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
kubectl create namespace efk
helm repo add elastic https://helm.elastic.co
helm search repo elastic
```

![image](https://github.com/user-attachments/assets/cbd10d22-cdbc-48d4-ab8f-99ebc362e576)

Please make sure whenever you want to install both ElasticSearch and Kibana, make sure that they are of the same version just like ```8.5.1``` for both.

When installing ElasticSearch, specify the name of the storage class (ebs-gp3) we deployed earlier and the storage value (5Gi) we are interested in.

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

Get the credentials to login to ElasticSearch

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
![image](https://github.com/user-attachments/assets/f9815a35-ba0a-4156-8034-a0cae4ef1a91)

![image](https://github.com/user-attachments/assets/ac34e8df-2660-44d8-8e2b-6ddeda31b467)

![image](https://github.com/user-attachments/assets/f10d4f37-80d6-4813-9524-ca7c6996bb3c)

![image](https://github.com/user-attachments/assets/0f2f9551-c69c-445e-bf79-61bc24018281)

![image](https://github.com/user-attachments/assets/dc63df4f-93f3-4ee3-b509-b7d02eb66e7c)

Deploy a log event generator

![image](https://github.com/user-attachments/assets/9dc839be-5ccd-4e43-afc2-9998cf2d94fe)

![image](https://github.com/user-attachments/assets/e35b8d09-3399-44a7-80b6-3295ced5a5fe)

Deploy Fluentbit using helm and edit the values.yaml

```
helm repo add fluent https://fluent.github.io/helm-charts
helm show values fluent/fluent-bit > fluentbit-values.yaml
```
Update the input section with the path where the app-event-simulator container log is located

![image](https://github.com/user-attachments/assets/cbcc5154-17c4-4821-8210-09c238c0fb10)

Also update the  output section with the highlighted part in the screenshot which includes the password of Elasticsearch, port, logstash prefix which is the way to identify the logs in Kibana

![image](https://github.com/user-attachments/assets/d2690eb5-c2b5-4bcc-90da-8ed62f56347f)

```
helm install fluent-bit fluent/fluent-bit -f fluentbit-values.yaml -n efk
```

![image](https://github.com/user-attachments/assets/6e06a115-1d66-4e76-b149-2587d8e23d0f)

![image](https://github.com/user-attachments/assets/5cabcc02-5b3f-49cd-87a7-6d23463111b9)

Fluentbit already getting the logs from the container

![image](https://github.com/user-attachments/assets/8980546d-d13b-4009-880c-c0265f8e0f4d)

Now, lets display the logs

![image](https://github.com/user-attachments/assets/a9c1406e-3f39-4f56-84c5-418c2c8f74c4)

![image](https://github.com/user-attachments/assets/c346bdc4-578e-43cf-966b-9df98bb6e57e)

![image](https://github.com/user-attachments/assets/64588dc7-b0f1-42de-89f5-40462f837975)

Give the log a name ```app-event-log``` and ensure the name given in the index pattern matches the index in the screenshot

![image](https://github.com/user-attachments/assets/30682f09-173a-4d8d-ac67-cd57b24868e4)

Now we have Kibana display our logs, in which we can also query the search bar with keys define in the logs

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














































