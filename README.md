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
1. **Launch Two Amazon Linux 2023 EC2 Instances (Free Tier).**
2. **Instance Configuration:**
   - **AMI:** Amazon Linux 2023 (64-bit x86)
   - **Instance Type:** `t2.micro`
   - **Key Pair:** Create a new key pair **“test&prod.pem”**.
   - **VPC:** Default VPC
   - **Storage:** EBS 10 GiB General Purpose SSD (gp3)

3. **Configure Security Group:**
   - **Inbound Rules:**
     - HTTP (80) → Anywhere (0.0.0.0/0, ::/0)
     - HTTPS (443) → Anywhere (0.0.0.0/0, ::/0)
     - TCP (3000, 8080) → Anywhere (0.0.0.0/0, ::/0)
     - SSH (22) → Anywhere (0.0.0.0/0, ::/0)
   - **Outbound Rules:**
     - Allow all traffic (0.0.0.0/0, ::/0).

4. **Install Dependencies on EC2:**
   ```bash
   sudo yum update -y
   sudo yum install -y git unzip nodejs npm aws-cli
   ```

5. **Install CodeDeploy Agent:**
   ```bash
   sudo yum install ruby -y
   cd /home/ec2-user
   wget https://aws-codedeploy-ap-south-1.s3.amazonaws.com/latest/install
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
1. **Go to AWS S3 Console** and create a new S3 bucket.
2. **Enable public access block** (recommended).
3. **Add a bucket policy** to allow access from AWS CodeDeploy.
4. **Update permissions** to allow CodeDeploy to access the bucket.

### **Step 5: Create IAM Roles**
1. **IAM Role for EC2:**
   - Attach `AmazonS3ReadOnlyAccess`, `CodeDeployFullAccess`.
2. **IAM Role for CodeDeploy:**
   - Attach `AmazonS3FullAccess`, `CodeDeployFullAccess`, `IAMPassRole`.

### **Step 6: Setup CodeDeploy**
1. **Create a CodeDeploy Application:**
   - Open the AWS CodeDeploy console.
   - Click **Create application**.
   - **Application Name:** `CICD-DEPLOY-MULTI`
   - **Compute Platform:** `EC2/On-Premises`
   - Click **Create application**.

2. **Create Deployment Groups:**
   - **Testing Deployment Group:**
     - Click **Create deployment group**.
     - **Deployment Group Name:** `Testing`
     - **Application Name:** `CICD-DEPLOY-MULTI`
     - **IAM Role:** `CodeDeployCustomRole`
     - **Deployment Type:** `In-Place Deployment`
     - **EC2 Instance:** Select **Testing EC2 Instance**
     - Click **Create deployment group**.
   
   - **Production Deployment Group:**
     - **Deployment Group Name:** `Production`
     - **EC2 Instance:** Select **Production EC2 Instance**
     - **Deployment Config:** `CodeDeployDefault.OneAtATime`
     - Click **Create deployment group**.

### **Step 7: Configure CodePipeline**
1. **Create a Custom CodePipeline:**
   - **Pipeline Name:** `Multi-Branch-Pipeline`
   - **Service Role:** `AWSCodePipelineServiceRole`
   - **S3 Bucket for Artifacts:** Select the previously created bucket.
   - **Add Stages:**
     1. **Source Stage:**
        - **Source Provider:** GitHub
        - **Repository:** Your project repository
        - **Branch:** `main`
        - **Output Artifact:** `SourceArtifact`
     2. **Deploy to Testing:**
        - **Provider:** AWS CodeDeploy
        - **Application Name:** `CICD-DEPLOY-MULTI`
        - **Deployment Group:** `Testing`
     3. **Manual Approval:**
        - **Approval Action:** Requires manual confirmation before production.
     4. **Deploy to Production:**
        - **Provider:** AWS CodeDeploy
        - **Application Name:** `CICD-DEPLOY-MULTI`
        - **Deployment Group:** `Production`
   - Click **Create Pipeline**.

### **Step 8: Deployment Process**
1. **Push code** to `testing`.
2. **CodePipeline triggers deployment** to testing.
3. **Manual approval required** before production.
4. **CodePipeline deploys** to production.
5. **GitHub Workflow auto-merges** changes.

---
## **Conclusion**
This project successfully implements a **CI/CD pipeline using AWS CodeDeploy, EC2, and GitHub** for automated deployments. 🚀

