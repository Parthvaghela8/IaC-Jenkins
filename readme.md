# Terraform CI/CD with Jenkins and GitHub Actions

This project automates Terraform operations using Jenkins as the CI/CD orchestrator. It triggers Jenkins jobs from GitHub Actions and runs them on a remote EC2 agent. The Jenkins master node is hosted on a Windows machine and exposed via Ngrok for external access.

## Project Overview
- **Jenkins Master Node**: Running on Windows and exposed via Ngrok for external access.
- **EC2 Agent**: A remote agent where the actual Terraform commands (plan, apply, destroy) are executed.
- **GitHub Actions**: Automates the triggering of Jenkins jobs based on changes to the repository.
- **Terraform**: Manages the infrastructure as code (IaC) with actions like plan, apply, and destroy.

## Prerequisites

Before you get started, ensure the following are set up:

### 1. Jenkins Master Node (Windows)
- Jenkins installed and running on a Windows machine.
- Ngrok set up to expose the Jenkins instance to the internet.

### 2. EC2 Agent Configuration
- An EC2 instance running and connected to your Jenkins master as a remote agent.
- Ensure the EC2 instance has Java and other necessary dependencies installed for Terraform execution.

### 3. GitHub Actions Workflow
- The workflow triggers Jenkins jobs based on changes pushed to the repository.
- GitHub Actions workflow uses a `config.json` file to specify the environment and Terraform action.

### 4. Terraform Files
- Terraform configuration files (`main.tf`, `dev.tfvars`, etc.) for defining your infrastructure.

## Setup

### 1. Configure Jenkins Master
- Install Jenkins on a Windows machine.
- Expose the Jenkins master using Ngrok to allow external access.
- Configure your EC2 instance as a Jenkins agent (either using SSH or JNLP).
- Set up AWS credentials and configure your Jenkins job (IaC) to trigger Terraform operations.

### 2. Configure EC2 as a Jenkins Agent
- Install Java on the EC2 instance (required for Jenkins agents).
- Install Jenkins agent on EC2 and connect it to the Jenkins master.
- The EC2 agent will execute Terraform commands defined in the pipeline.

### 3. GitHub Actions Workflow
Create a `.github/workflows/ci.yml` file to define your CI/CD pipeline. The workflow will:
- Checkout the code from GitHub.
- Set up Terraform.
- Run `terraform init`, `terraform fmt`, and `terraform validate` to validate Terraform configurations.
- Load the configuration from the `config.json` file.
- Check the reachability of the Jenkins instance.
- Trigger the Jenkins job with parameters like environment and Terraform action.

## 4. config.json
This file contains the parameters that are passed from GitHub Actions to Jenkins:

```json
{
  "environment": "dev",
  "terraform_action": "plan",
  "jenkins_job": "IaC",
  "jenkins_url": "https://<ngrok-url>/"
}
```

## 5. Terraform Files
Place your Terraform files (`main.tf`, `dev.tfvars`, etc.) in the repository. Terraform will execute the operations based on the selected environment and action (plan, apply, destroy).

## 6. Jenkins Pipeline (Jenkinsfile)
The Jenkinsfile defines the pipeline stages and Terraform commands. It will run on the EC2 agent.

## Conclusion
This project automates Terraform operations using Jenkins and GitHub Actions. The Jenkins master node runs on a Windows machine, while the EC2 instance is used as a remote agent to execute Terraform commands. The workflow allows for easy and automated infrastructure management with consistent, repeatable Terraform deployments.
