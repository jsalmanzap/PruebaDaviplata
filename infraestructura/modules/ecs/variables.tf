variable "project_name" { type = string }
variable "environment" { type = string }
variable "aws_region" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "alb_security_group_id" { type = string }
variable "target_group_arn" { type = string }
variable "container_image" { type = string }

variable "app_port" {
  type    = number
  default = 8000
}

variable "task_cpu" {
  type    = number
  default = 256
}

variable "task_memory" {
  type    = number
  default = 512
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "log_retention_days" {
  type    = number
  default = 7
}

variable "secret_arns" {
  type        = list(string)
  default     = []
  description = "ARNs de secretos en Secrets Manager inyectados al contenedor"
}

variable "min_capacity" {
  type        = number
  default     = 1
  description = "Número mínimo de tasks ECS — el auto-scaler nunca baja de este valor"
}

variable "max_capacity" {
  type        = number
  default     = 2
  description = "Número máximo de tasks ECS — el auto-scaler nunca sube de este valor"
}

variable "autoscaling_cpu_target" {
  type        = number
  default     = 70
  description = "Porcentaje de CPU promedio que dispara el escalado horizontal"
}
