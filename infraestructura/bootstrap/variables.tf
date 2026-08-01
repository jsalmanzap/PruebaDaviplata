variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type = string
}

variable "aws_account_id" {
  type        = string
  description = "ID de la cuenta AWS (usado como sufijo del bucket de estado)"
}

variable "github_repo" {
  type        = string
  description = "Repositorio GitHub con formato owner/repo"
}
