# Istio
Open Source Istio with Bookinfo applicaiton


## Table of Contents
1. [Heart Rate Monitor](README.md#Heart_Rate_Monitor)
1. [Auto Deployment](README.md#Auto_Deployment)
1. [Requirements](README.md#Requirements)
1. [Platform Architecture](README.md#Platform_Architecture)
1. [Challenge](README.md#Challenge)
1. [DevOps](README.md#DevOps)


## Heart Rate Monitor

Heart Rate Moniotor is an Insight engineered application that takes in real-time streaming data to produce ECG records and display irregular patient information. The application could be used by healthcare providers to monitor any life-threathening events or to diagnose cardiac arrhythmia.


## Auto Deployment

This DevOps project was to deploy the application data pipeline infrastructure with just one-click by using Terraform. Here are the core packages used in Heart Rate Monitor:

Python 3.6
Nginx, Gunicorn and Flask
Cassandra cluster
Spark Streaming cluster
Kafka cluster
S3 Bucket


## Security Group Auto Remedy

Second challenge is to automate some security remedy by using Cloud Trail, CloudWatch, and Lambda.


## Requirements


Terraform : https://learn.hashicorp.com/terraform/getting-started/install.html
AWS-IAM : https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
AWS Credential: Export AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY to Host Environment



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
