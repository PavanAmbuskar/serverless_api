provider "aws" {
  region = var.region
}

resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-${var.stage}-sg"
  description = "Allow SSH, Grafana (3000), Jenkins (8080)"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "devops_ec2" {
  ami           = ami-065778886ef8ec7c8
  instance_type = "t3.micro"
  key_name   = "sever.pem"
  security_groups = serverless

  # IAM role so Terraform and Lambda can run directly
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get upgrade -y

              # Install basic tools
              apt-get install -y unzip curl git jq zip

              # Install AWS CLI v2
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip -q awscliv2.zip
              ./aws/install

              # Install Terraform
              curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp.gpg
              echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list
              apt-get update && apt-get install terraform -y

              # Install Docker
              apt-get install -y docker.io
              systemctl enable docker
              systemctl start docker
              usermod -aG docker ubuntu

              # Install Jenkins
              curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
              echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/ > /etc/apt/sources.list.d/jenkins.list
              apt-get update -y
              apt-get install -y openjdk-17-jre-headless jenkins
              systemctl enable jenkins
              systemctl start jenkins

              # Download Grafana .deb
              wget https://dl.grafana.com/oss/release/grafana_10.4.2_amd64.deb -O grafana.deb

              # Install Grafana
              sudo dpkg -i grafana.deb || sudo apt-get install -f -y

              # Enable & start Grafana
              sudo systemctl enable grafana-server
              sudo systemctl start grafana-server
              EOF

  tags = {
    Name = "${var.project_name}-${var.stage}-ec2"
  }
}

# Ubuntu AMI (latest LTS in us-east-1)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# IAM role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-${var.stage}-ec2-role"

  assume_role_policy = <<-EOP
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": { "Service": "ec2.amazonaws.com" },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOP
}

resource "aws_iam_role_policy_attachment" "ec2_admin_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-${var.stage}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

output "ec2_public_ip" {
  value = aws_instance.devops_ec2.public_ip
}

