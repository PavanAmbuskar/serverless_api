pipeline {
    agent any

    parameters {
        choice(
            name: 'ACTION',
            choices: ['apply', 'destroy'],
            description: 'Choose whether to deploy or destroy the infrastructure'
        )
    }

    environment {
        AWS_DEFAULT_REGION = "us-east-1"
        LAMBDA_BUCKET      = "serverless-api-lambda-artifacts"
        TF_BACKEND_BUCKET  = "my-terraform-state-bucket"   // S3 bucket for remote state
        TF_BACKEND_KEY     = "serverless-api/terraform.tfstate"
        TF_BACKEND_TABLE   = "terraform-locks"            // DynamoDB table for state locking
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/PavanAmbuskar/serverless_api.git',
                    credentialsId: 'github-creds'
            }
        }

        stage('Package Lambda') {
            steps {
                sh '''
                rm -f lambda_function.zip
                zip -j lambda_function.zip lambda/handler.py
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    dir('terraform') {
                        sh '''
                        terraform init -input=false \
                            -backend-config="bucket=${TF_BACKEND_BUCKET}" \
                            -backend-config="key=${TF_BACKEND_KEY}" \
                            -backend-config="region=${AWS_DEFAULT_REGION}" \
                            -backend-config="dynamodb_table=${TF_BACKEND_TABLE}"
                        '''
                    }
                }
            }
        }

        stage('Terraform Action') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    dir('terraform') {
                        script {
                            if (params.ACTION == 'apply') {
                                sh 'echo "run successfully"'
                            } else if (params.ACTION == 'destroy') {
                                sh 'terraform destroy -auto-approve -input=false'
                            }
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ Terraform ${params.ACTION} completed successfully."
        }
        failure {
            echo "❌ Terraform ${params.ACTION} failed."
        }
    }
}

