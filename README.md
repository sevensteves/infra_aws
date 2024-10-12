# AWS Infrastructure for Deploying Dockerized Web Services

This repository contains the Terraform code used to provision AWS infrastructure, including an ECS cluster, VPC, and security groups. It is designed to automate the deployment of Dockerized web services using ECS Fargate and integrates with GitHub Actions for continuous delivery.

![Terraform](https://img.shields.io/badge/Terraform-v1.9.7-blue)
![GitHub Actions](https://img.shields.io/github/actions/workflow/status/your-repo/main.yml?branch=main)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

## Table of Contents
- [Project Overview](#project-overview)
- [Infrastructure Setup](#infrastructure-setup)
- [Deployment Instructions](#deployment-instructions)
- [GitHub Actions CI/CD](#github-actions-ci/cd)
- [Usage](#usage)
- [License](#license)

## Infrastructure Setup
The following AWS resources are provisioned using Terraform:
- ECS Cluster
- VPC with public subnets
- Security Groups for ECS Services

### Prerequisite
- **S3 Bucket for Terraform State**: You need to manually create an S3 bucket to store Terraform state. This bucket is not provisioned by Terraform.

#### Why Is the S3 Bucket Not Created Automatically?

The S3 bucket for storing Terraform state needs to exist before Terraform can run because Terraform itself uses this bucket to store the state file. Since Terraform requires a state file to track infrastructure changes, the S3 bucket needs to be created manually or through a separate process before the main Terraform configuration can be applied. Automating its creation with Terraform would create a dependency loop where Terraform requires the S3 bucket to run but also tries to create it.

## Deployment Instructions
To deploy this infrastructure, follow these steps:

1. Clone or fork the repository:
   ```bash
   git clone https://github.com/your-repo/aws-infrastructure.git
   ```

2. Set up AWS credentials in GitHub secrets (`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`).

3. Setup your region in GitHub variables (`AWS_REGION`).
   
4. **Manually create an S3 bucket** in AWS to store Terraform state, and configure the backend in the `main.tf` file like so:

   ```hcl
   terraform {
     backend "s3" {
       bucket = "your-bucket-name"
       key    = "terraform/state/terraform.tfstate"
       region = "your-region"
     }
   }
   ```

5. Modify the `variables.tf` file to suit your AWS environment.

6. Trigger the GitHub Actions workflow by pushing to the `main` branch or running `terraform apply` locally.

## GitHub Actions CI/CD
This project uses GitHub Actions to automate the deployment and management of the infrastructure:

- **Terraform Plan and Apply**: Automatically runs when changes are pushed to the `main` branch.
- **Terraform Destroy**: You can destroy the infrastructure by triggering the workflow with the `destroy` input set to `true`.

Example command to trigger a destroy:
```bash
gh workflow run terraform.yml --ref main -f destroy=true
```

## Usage
After deploying the infrastructure, you can start deploying your web services to the ECS cluster by pushing Docker images to ECR.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
