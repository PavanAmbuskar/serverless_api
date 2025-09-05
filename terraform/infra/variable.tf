variable "region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "tf-serverless"
}

variable "stage" {
  default = "dev"
}

variable "public_key_path" {
  description = "Path to your SSH public key (for EC2 login)"
  default     = "~/.ssh/id_rsa.pub"
}
