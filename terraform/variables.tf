variable "region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "tf-serverless"
}

variable "stage" {
  type    = string
  default = "dev"
}

variable "alarm_error_rate_threshold" {
  type    = number
  default = 0.05
}

variable "notification_email" {
  type    = string
  default = "pavanambuskar12@gmail.com"
}
