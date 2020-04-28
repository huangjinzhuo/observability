# Service Observability with Istio, Prometheus, Grafana, Jaeger, and Kiali
Sample applications in this demo are Bookinfo from open source Istio repository, and Hyster from Google Cloud Platform. They are both cloned to this repo.


## Table of Contents
1. [Requirements](README.md#Requirements)
1. [Istio Installation](README.md#Istio_Installation)
1. [Deployment](README.md#Deployment)
1. [Platform Architecture](README.md#Platform_Architecture)
1. [Challenge](README.md#Challenge)
1. [DevOps](README.md#DevOps)


## Requirements


Terraform : https://learn.hashicorp.com/terraform/getting-started/install.html
AWS-IAM : https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
AWS Credential: Export AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY to Host Environment



## Istio Installation


## Deployment

To deploy Hypster :

Python 3.6
Nginx, Gunicorn and Flask

To deploy Bookinfo:




## Platform Architecture

https://github.com/huangjinzhuo/keep_it_beating/blob/master/images/Keep_It_Beating_Platform_Arch.svg



## Challenge

* One-click deployment to deploy servers in various requirement.
* Auto remedy when special security group is changed.

## DevOps

### 1. Provision Platform on AWS

The following step spins up Kafka cluster, Spark cluster, Cassandra cluster, Flask server, and Bastian jump box as AWS EC2 instances, as well as security groups, public and private subnets, VPC. It will take ~15 mins to set up.

cd terraform
terraform init
terraform apply

### 2. Destroy Platform
The following command stops and destroys the deployed instances. It will take ~10 mins to complete.

terraform destroy
