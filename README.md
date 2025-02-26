# **AWS CI/CD Pipeline with GitHub and CodeDeploy**

## **Overview**
This project sets up a complete **CI/CD pipeline** for a **Node.js application and an HTML website** using **AWS EC2, CodeDeploy, CodePipeline, S3, and GitHub**. The pipeline follows a **multi-branch deployment strategy** (`main`, `testing`, `production`) with **manual approvals** before production releases.

---
## **Project Architecture**

### **Components:**
- **EC2 Instances (Linux, Free Tier)**: Hosts the application.
- **Security Group**: Allows traffic on **ports 80, 443, 3000, and 8080**.
- **GitHub Repository**: Stores project code with branch-based deployment.
- **S3 Bucket**: Stores deployment artifacts.
- **IAM Roles**: Grants permissions for EC2 and CodeDeploy.
- **AWS CodeDeploy**: Handles deployments.
- **AWS CodePipeline**: Automates deployment workflows.
- **GitHub Workflow**: Auto-merges changes post-deployment.

---
## **Prerequisites**
- **AWS Free Tier Account**
- **GitHub Account**
- **Node.js & NPM Installed**
- **Git Installed**
- **AWS CLI Installed & Configured**
- **VS Code (or any IDE)**

---
## **Setup & Configuration**

### **Step 1: Create EC2 Instances**
1. **Launch Two Amazon Linux 2 EC2 Instances (Free Tier).**
2. **Configure Security Group:**
   - **Inbound Rules:**
     - HTTP (80), HTTPS (443), TCP (3000, 8080)
   - **Outbound Rules:**
     - Allow all traffic.
3. **Install Dependencies on EC2:**
   ```bash
   sudo yum update -y
   sudo yum install -y git unzip nodejs npm aws-cli
   ```
4. **Install CodeDeploy Agent:**
   ```bash
   sudo yum install ruby -y
   cd /home/ec2-user
   wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
   chmod +x ./install
   sudo ./install auto
   sudo systemctl enable codedeploy-agent
   sudo systemctl start codedeploy-agent
   ```

### **Step 2: Setup GitHub Repository**
1. **Create a new GitHub repository.**
2. **Push a simple Node.js website.**
3. **Create branches:** `main`, `testing`, `production`.

### **Step 3: Generate GitHub Token**
1. **Generate a Personal Access Token** with permissions:
   - **Content:** Read & Write
   - **Workflows:** Read & Write
   - **Metadata:** Read Only
2. **Store the Token in GitHub Secrets:**
   - **Key:** `GT_TAH`
   - **Value:** (Paste Token)

### **Step 4: Create S3 for Artifacts**
1. **Create an S3 Bucket** (for storing deployment artifacts).
2. **Update permissions** to allow CodeDeploy access.

### **Step 5: Create IAM Roles**
1. **IAM Role for EC2:**
   - Attach `AmazonS3ReadOnlyAccess`, `CodeDeployFullAccess`.
2. **IAM Role for CodeDeploy:**
   - Attach `AmazonS3FullAccess`, `CodeDeployFullAccess`, `IAMPassRole`.

### **Step 6: Setup CodeDeploy**
1. **Create a CodeDeploy Application:**
   - Name: `MyApp`
   - Compute Platform: `EC2/On-Premises`
2. **Create Deployment Groups:**
   - **Testing:** Uses EC2 testing instance.
   - **Production:** Uses EC2 production instance.

### **Step 7: Configure CodePipeline**
1. **Pipeline Stages:**
   - **Source:** Fetches code from GitHub.
   - **Deploy to Testing:** Deploys to `testing`.
   - **Manual Approval:** Requires approval before production.
   - **Deploy to Production:** Deploys to `production`.

### **Step 8: Deployment Process**
1. **Push code** to `testing`.
2. **CodePipeline triggers deployment** to testing.
3. **Manual approval required** before production.
4. **CodePipeline deploys** to production.
5. **GitHub Workflow auto-merges** changes.

---
## **Project Structure**
```
├── src/
│   ├── index.js  # Node.js App Entry Point
├── deploy/
│   ├── appspec.yml  # AWS CodeDeploy Config
│   ├── scripts/
│       ├── start.sh  # Startup Script
│       ├── stop.sh   # Stop Script
├── .github/workflows/deploy.yml  # GitHub Actions Workflow
├── package.json  # Node.js Dependencies
├── README.md  # Project Documentation
```

---
## **GitHub Actions Workflow (`.github/workflows/deploy.yml`)**
```yaml
name: Deploy to AWS
on:
  push:
    branches:
      - testing
      - production
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
      - name: Deploy to AWS CodeDeploy
        run: |
          aws deploy create-deployment --application-name MyApp --deployment-group-name ${{ github.ref_name }} --s3-location bucket=my-artifacts-bucket,key=latest.zip,bundleType=zip
```

---
## **Deployment Guide**
1. **Commit & push code** to `testing`.
2. **CodePipeline deploys** to testing.
3. **Manual approval required** before production.
4. **CodePipeline deploys** to production.
5. **GitHub Workflow auto-merges** changes.

---
## **Troubleshooting & FAQs**

### **1. CodeDeploy Fails?**
- Check IAM role permissions.
- Verify `appspec.yml` configuration.

### **2. Pipeline Stuck at Manual Approval?**
- Approve manually in AWS CodePipeline.

### **3. EC2 Instance Not Updating?**
- Restart EC2: `sudo reboot`.
- Check logs: `tail -f /var/log/codedeploy-agent.log`.

---
## **Contributors & License**
- **Author:** Nirmal Padvi
- **License:** MIT License

---
## **Conclusion**
This project successfully implements a **CI/CD pipeline using AWS CodeDeploy, EC2, and GitHub** for automated deployments. 🚀

