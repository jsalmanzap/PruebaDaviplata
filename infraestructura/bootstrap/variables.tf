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

variable "github_repo_immutable" {
  type        = string
  description = "Repositorio GitHub con formato owner@owner_id/repo@repo_id (claim 'sub' inmutable que GitHub usa tras un rename de owner/repo)"
  default     = ""
}
