# AWS CI/CD Pipeline with GitHub and CodeDeploy

## Project Overview
This project sets up a complete CI/CD pipeline for a simple Node.js application using AWS CodeDeploy, CodePipeline, S3, and GitHub. The deployment process follows a multi-branch strategy (`main`, `testing`, `production`), ensuring controlled releases with manual approvals before production deployment.

## System Requirements
- AWS Free Tier Account
- GitHub Account and Git installed
- Node.js Installed (for local development)
- AWS CLI Installed & Configured
- VS Code (IDE)

## Setup and Configuration

### Step 1: Create a GitHub Repository
1. Create a new repository named `CICD-LAST`.
2. Do not initialize it with a README, license, or `.gitignore`.
3. Clone the repository locally and initialize a Node.js project:
   ```sh
   cd /path/to/your/project/folder
   npm init -y
   npm install express
   ```
4. Create `app.js`:
   ```js
   const express = require("express");
   const app = express();
   const PORT = 8080;
   const HOST = "0.0.0.0";
   
   app.get("/", (req, res) => {
     res.send("Hello, Toshal Infotech AWS TEAM!!!");
   });
   
   app.listen(PORT, HOST, () => {
     console.log(`Server running on http://${HOST}:${PORT}`);
   });
   ```
5. Push to GitHub:
   ```sh
   git init
   git remote add origin https://github.com/your-username/CICD-LAST.git
   git add .
   git commit -m "Initial commit with simple Node.js app"
   git push -u origin main
   ```
6. Create branches: `testing`, `production`.

### Step 2: Configure GitHub Authentication Token
1. Generate a **Personal Access Token (PAT)** in GitHub with `Content: Read & Write`, `Workflows: Read & Write`, and `Metadata: Read Only` permissions.
2. Add this token as a **GitHub Secret** with the key `GH_PAT`.

### Step 3: Auto-Merge Workflow (GitHub Actions)
Create `.github/workflows/auto-merge.yml`:
```yaml
on:
  push:
    branches:
      - testing
  workflow_dispatch:

jobs:
  merge-to-production:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          token: ${{ secrets.GH_PAT }}

      - name: Configure Git
        run: |
          git config --global user.email "Nirmalp2632@gmail.com"
          git config --global user.name "GitHub Actions Bot"

      - name: Merge Testing into Production
        run: |
          git checkout production
          git merge origin/testing --no-edit
          git push origin production
```

### Step 4: EC2 Setup
1. Create two EC2 instances (`Testing` & `Production`):
   - **Type:** `t2.micro`
   - **AMI:** Amazon Linux 2023
   - **Security Group:** Open ports 80, 443, 8080, and 22.
2. Install dependencies on EC2:
   ```sh
   sudo yum update -y
   sudo yum install -y git unzip nodejs npm aws-cli
   sudo npm install -g pm2
   ```
3. Install CodeDeploy Agent:
   ```sh
   sudo yum install ruby -y
   cd /home/ec2-user
   wget https://aws-codedeploy-ap-south-1.s3.amazonaws.com/latest/install
   chmod +x ./install
   sudo ./install auto
   sudo systemctl enable codedeploy-agent
   sudo systemctl start codedeploy-agent
   ```

### Step 5: IAM Roles
1. **IAM Role for EC2**:
   - Attach policies: `AmazonS3ReadOnlyAccess`, `CodeDeployFullAccess`, `AmazonEC2FullAccess`, `AmazonCodePipeline`.
   - Assign to both EC2 instances.
2. **IAM Role for CodeDeploy**:
   - Attach policies: `AmazonS3FullAccess`, `CodeDeployFullAccess`, `IAMPassRole`, `AmazonEC2FullAccess`.
   - Assign to CodeDeploy.

### Step 6: Setup CodeDeploy
1. **Create a CodeDeploy Application**:
   - Name: `CICD-DEPLOY-MULTI`
   - Compute Platform: `EC2/On-Premises`
2. **Create Deployment Groups**:
   - **Testing Deployment Group**:
     - Application: `CICD-DEPLOY-MULTI`
     - EC2 Instance: Select Testing EC2 Instance
   - **Production Deployment Group**:
     - EC2 Instance: Select Production EC2 Instance

### Step 7: Configure CodePipeline
1. **Create a CodePipeline**:
   - Name: `Multi-Branch-Pipeline`
   - Service Role: `AWSCodePipelineServiceRole`
   - **Stages**:
     - **Source**: GitHub (`main` branch)
     - **Deploy to Testing**: AWS CodeDeploy (Testing Group)
     - **Manual Approval**: Required before production deployment
     - **Deploy to Production**: AWS CodeDeploy (Production Group)

### Step 8: Configure SNS for Deployment Notifications
1. **Create an SNS Topic**:
   - Name: `DeploymentNotifications`
   - Add email subscription: `nirmalp2632@gmail.com`
2. **Attach SNS to CodeDeploy**:
   - Go to AWS CodeDeploy > Select Testing Deployment Group
   - Under **Triggers**, add SNS Topic `DeploymentNotifications`
   - Configure for deployment success & failure.
     
### Step 9: Configure EC2 Instance Monitoring with Grafana, Prometheus, Loki, and Promtail
1. Install CodeDeploy Agent:
   ```sh
   wget https://github.com/prometheus/prometheus/releases/latest/download/prometheus-linux-amd64.tar.gz
   ```
2. Extract and move it:
   ```sh
   tar -xvzf prometheus-linux-amd64.tar.gz
   sudo mv prometheus-linux-amd64 /usr/local/bin/prometheus
   ```
3. Create Prometheus configuration file at /etc/prometheus/prometheus.yml:
   ```sh
   global:
     scrape_interval: 15s
   
   scrape_configs:
     - job_name: 'node_exporter'
       static_configs:
         - targets: ['localhost:9100']
    ```
## Conclusion
- Successfully integrates GitHub, AWS CodeDeploy, and AWS CodePipeline.
- Implements a **multi-branch** deployment strategy for structured releases.
- Uses **manual approvals** for controlled production deployments.
- Sends **SNS notifications** for deployment status updates.

## Summary
- A **Node.js** app is deployed on AWS EC2.
- **AWS CodePipeline** automates deployment from GitHub.
- **Manual approvals** ensure controlled production releases.
- **SNS notifications** provide real-time updates.

---
This README serves as a complete guide to setting up an AWS CI/CD pipeline with GitHub and CodeDeploy.
