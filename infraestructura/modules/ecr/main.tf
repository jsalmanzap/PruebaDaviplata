resource "aws_ecr_repository" "app" {
  #checkov:skip=CKV_AWS_136: KMS para ECR requiere una CMK dedicada; se añadiría en hardening de prod
  name                 = "${var.project_name}-${var.environment}"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration { scan_on_push = true }
  encryption_configuration { encryption_type = "AES256" }

  tags = { Name = "${var.project_name}-${var.environment}", Environment = var.environment }
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Mantener las últimas 10 imágenes"
      selection    = { tagStatus = "any", countType = "imageCountMoreThan", countNumber = 10 }
      action       = { type = "expire" }
    }]
  })
}
