# Multi-Architecture AWS Infrastructure Deployment with Terraform

This repository contains a progressive, multi-stage cloud infrastructure implementation on Amazon Web Services (AWS) using **Terraform (HCL)**. The project demonstrates deploying a full-stack web application—comprising a **Node.js/Express frontend** and a **Python/Flask backend API**—across three evolving cloud architecture patterns.

---

## 📌 Project Overview

| Architectural Stage | Compute Model | Networking & Isolation | Key Services / Tools |
| :--- | :--- | :--- | :--- |
| **Part 1: Single EC2** | 1x EC2 Instance (Co-located services) | Public IP with custom SG rules | EC2, Cloud-Init (`user_data.sh`), Python, Node.js |
| **Part 2: Multi-EC2 VPC** | 2x Dedicated EC2 Instances (Frontend & Backend) | Custom VPC, Subnets, Tiered Security Groups | AWS VPC, Internet Gateway, EC2, User Data scripts |
| **Part 3: ECS Fargate** | Serverless Containers (0.25 vCPU / 0.5 GB) | Multi-AZ VPC, ECR, Path-Based ALB Routing | AWS ECR, ECS Fargate, ALB, S3 Remote State |

---

## 📂 Repository Directory Structure

```text
.
├── README.md                          # Root Repository Documentation
├── tf-part-1/                         # Part 1: Single EC2 Instance
│   ├── main.tf                        # EC2, Security Group & Key Pair definitions
│   ├── provider.tf                    # AWS Provider configuration
│   ├── variables.tf                   # Input variables (AMI, Instance Type, Ports)
│   ├── terraform.tfvars               # Variable values
│   ├── outputs.tf                     # EC2 Public IP & Service URLs
│   ├── user_data.sh                   # Cloud-Init script for single instance
│   ├── express-frontend/              # Node.js Express frontend application
│   └── flask-backend/                 # Python Flask backend API
├── tf-part-2/                         # Part 2: Separate EC2 Instances in Custom VPC
│   ├── main.tf                        # VPC, Subnets, Routing, SGs, & 2x EC2 instances
│   ├── provider.tf                    # AWS Provider configuration
│   ├── variables.tf                   # Network & Compute variables
│   ├── terraform.tfvars               # Environment variable assignments
│   ├── outputs.tf                     # Frontend & Backend public/private IPs
│   ├── express-user-data.sh           # Bootstrap script for Express EC2
│   ├── flask-user-data.sh             # Bootstrap script for Flask EC2
│   ├── express-frontend/              # Express source code
│   └── flask-backend/                 # Flask source code
└── tf-part-3/                         # Part 3: Containerized ECS Fargate with ECR & ALB
    ├── express-frontend/              # Frontend with Dockerfile
    │   └── Dockerfile
    ├── flask-backend/                 # Backend with Dockerfile
    │   └── Dockerfile
    └── terraform/                     # Modular Infrastructure Code
        ├── backend.tf                 # S3 Remote State configuration
        ├── providers.tf               # AWS Provider configuration (>= 5.0)
        ├── variables.tf               # Region, VPC, Container Ports
        ├── ecr.tf                     # Amazon ECR Repositories (Flask & Express)
        ├── vpc.tf                     # Custom VPC, 2 Public Subnets, IGW, Route Tables, SGs
        ├── alb.tf                     # Application Load Balancer & Path Rules
        ├── ecs.tf                     # ECS Cluster, Task Definitions, Fargate Services
        └── outputs.tf                 # ALB DNS URL & ECR Repository URLs
```

---

## 🚀 Getting Started & Prerequisites

### Required Tools
* **Terraform** (`>= 1.5.0`)
* **AWS CLI** (`v2`) configured with appropriate credentials
* **Docker Engine** (`>= 24.0`)
* **Git**

---

## 🛠 Deployment Instructions

### 🔹 Part 1: Single EC2 Deployment
```bash
cd tf-part-1
terraform init
terraform plan
terraform apply -auto-approve
```
* Access Express Frontend: `http://<EC2-PUBLIC-IP>:3000`
* Access Flask Backend API: `http://<EC2-PUBLIC-IP>:5000`

### 🔹 Part 2: Separate EC2 Instances Deployment
```bash
cd tf-part-2
terraform init
terraform plan
terraform apply -auto-approve
```
* Access Express Frontend: `http://<EXPRESS-EC2-PUBLIC-IP>:3000`
* Access Flask Backend API: `http://<FLASK-EC2-PUBLIC-IP>:5000`

### 🔹 Part 3: ECR, ECS Fargate & ALB Deployment

#### 1. Provision ECR Repositories
```bash
cd tf-part-3/terraform
terraform init
terraform apply -target=aws_ecr_repository.flask -target=aws_ecr_repository.express -auto-approve
```

#### 2. Build & Push Docker Images to ECR
```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.ap-south-1.amazonaws.com

# Build & Push Flask Image
cd ../flask-backend
docker build -t ${ACCOUNT_ID}.dkr.ecr.ap-south-1.amazonaws.com/ecs-assignment-flask:latest .
docker push ${ACCOUNT_ID}.dkr.ecr.ap-south-1.amazonaws.com/ecs-assignment-flask:latest

# Build & Push Express Image
cd ../express-frontend
docker build -t ${ACCOUNT_ID}.dkr.ecr.ap-south-1.amazonaws.com/ecs-assignment-express:latest .
docker push ${ACCOUNT_ID}.dkr.ecr.ap-south-1.amazonaws.com/ecs-assignment-express:latest
```

#### 3. Deploy VPC, ALB, and ECS Services
```bash
cd ../terraform
terraform plan
terraform apply -auto-approve
```
* Access Full-Stack Application via ALB: `http://<ALB-DNS-NAME>/`

---

## 🧹 Resource Teardown
To avoid unwanted AWS billing charges, destroy resources when finished:
```bash
# Destroy Part 3
cd tf-part-3/terraform && terraform destroy -auto-approve

# Destroy Part 2
cd ../../tf-part-2 && terraform destroy -auto-approve

# Destroy Part 1
cd ../tf-part-1 && terraform destroy -auto-approve
```

---