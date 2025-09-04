 🚀 Serverless REST API with Monitoring & CI/CD
This project implements a **serverless REST API** using **AWS Lambda, API Gateway, and DynamoDB**, with full **Infrastructure as Code (IaC)** via **Terraform**.  
It also integrates **CloudWatch monitoring with SNS alerts**, a **Jenkins CI/CD pipeline**, and a **Grafana dashboard** for observability.  

📌 Features
- **AWS Lambda (Python 3.11)** – Handles business logic.
- **API Gateway** – Provides RESTful endpoints for interaction.
- **DynamoDB** – Stores items in a NoSQL table.
- **Terraform** – Provisions and manages all AWS infrastructure.
- **CloudWatch & SNS** – Monitors Lambda errors and sends alerts.
- **Jenkins CI/CD** – Automates packaging and deployment of Lambda.
- **Grafana Dashboard** – Visualizes API metrics in real-time.

🏗️ Architecture
1. Client sends requests to **API Gateway**.
2. API Gateway invokes the **Lambda function**.
3. Lambda reads/writes data in **DynamoDB**.
4. **CloudWatch** stores logs and metrics.
5. **SNS** sends alerts when errors exceed threshold.
6. **Grafana** displays API metrics.
7. **Jenkins pipeline** automates build and deployment.

📂 Project Structure
serverless-api/
│── lambda/ # Lambda function code
│ └── handler.py
│── terraform/ # Terraform IaC files
│ ├── main.tf
│ ├── lambda.tf
│ ├── apigateway.tf
│ ├── dynamodb.tf
│ ├── monitoring.tf
│ ├── variables.tf
│ └── outputs.tf
│── Jenkinsfile # CI/CD pipeline definition
│── README.md # Project documentation

⚙️ Setup & Deployment
1️⃣ Prerequisites
- AWS CLI installed and configured (`aws configure`)
- Terraform installed (`terraform -v`)
- Jenkins installed (for CI/CD)
- Grafana (running on EC2 or Docker)

---

### 2️⃣ Deploy Infrastructure
```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve

This will create:
•	Lambda function
•	API Gateway REST API
•	DynamoDB table
•	CloudWatch alarm + SNS alert

📊 Monitoring & CI/CD
✅ CloudWatch + SNS Alerts
•	Logs stored in CloudWatch.
•	CloudWatch Alarm triggers when Lambda errors exceed threshold.
•	SNS Topic sends email alerts for failures.
✅ Jenkins Pipeline
Stages:
1.	Checkout code from GitHub
2.	Build Lambda package
3.	Run Tests
4.	Deploy with Terraform
✅ Grafana Dashboards
•	Displays Lambda Invocations, Errors, and API Latency.
•	Integrated with CloudWatch as data source.
________________________________________
📧 Alerts
You will receive an email alert from SNS if Lambda errors cross the defined threshold.
________________________________________
📜 Outputs
After deployment, Terraform prints:
•	API Invoke URL
•	DynamoDB Table Name
•	Lambda Function Name
•	SNS Topic ARN
________________________________________
🛠️ Tools & Technologies
•	AWS Lambda
•	Amazon API Gateway
•	Amazon DynamoDB
•	Terraform
•	AWS CloudWatch & SNS
•	Jenkins
•	Grafana

