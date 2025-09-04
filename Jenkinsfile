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
        LAMBDA_BUCKET      = "serverless-api-lambda-artifacts"
        TF_BACKEND_BUCKET  = "my-terraform-state-bucket"
        TF_BACKEND_KEY     = "serverless-api/terraform.tfstate"
        TF_BACKEND_TABLE   = "terraform-locks"
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
                        script {
                            // 🔍 Get region of the bucket dynamically
                            def bucketRegion = sh(
                                script: "aws s3api get-bucket-location --bucket ${TF_BACKEND_BUCKET} --query 'LocationConstraint' --output text",
                                returnStdout: true
                            ).trim()

                            if (bucketRegion == "None") {
                                bucketRegion = "us-east-1" // AWS returns None for us-east-1
                            }

                            echo "Detected S3 bucket region: ${bucketRegion}"

                            sh """
                            terraform init -reconfigure -input=false \
                                -backend-config="bucket=${TF_BACKEND_BUCKET}" \
                                -backend-config="key=${TF_BACKEND_KEY}" \
                                -backend-config="region=${bucketRegion}" \
                                -backend-config="dynamodb_table=${TF_BACKEND_TABLE}"
                            """
                        }
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
                                sh 'terraform plan -input=false -out=tfplan'
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
