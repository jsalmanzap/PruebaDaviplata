variable "project_name" {
  type    = string
  default = "microservicio-echo"
}
variable "environment" {
  type    = string
  default = "prod"
}
variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "vpc_cidr" {
  type    = string
  default = "10.2.0.0/16"
}
variable "app_port" {
  type    = number
  default = 8000
}

variable "container_image" {
  type        = string
  description = "URI completa de la imagen ECR. El pipeline la sobreescribe en cada deploy."
}

variable "task_cpu" {
  type    = number
  default = 512
}
variable "task_memory" {
  type    = number
  default = 1024
}
variable "desired_count" {
  type    = number
  default = 2
}
variable "log_retention_days" {
  type    = number
  default = 30
}
variable "min_capacity" {
  type    = number
  default = 1
}
variable "max_capacity" {
  type    = number
  default = 2
}
variable "autoscaling_cpu_target" {
  type    = number
  default = 70
}
