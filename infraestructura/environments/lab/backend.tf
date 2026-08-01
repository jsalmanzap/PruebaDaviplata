terraform {
  backend "s3" {
    # bucket y dynamodb_table se inyectan en 'terraform init -backend-config=...'
    # desde el workflow (tf-infra.yml) usando el Account ID de OIDC.
    # Para uso local: terraform init -backend-config=../../bootstrap/backend.hcl
    key     = "lab/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
