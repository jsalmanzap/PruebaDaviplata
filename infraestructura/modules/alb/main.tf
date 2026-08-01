resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Permite trafico HTTP entrante al ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP desde internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #checkov:skip=CKV_AWS_260: Puerto 80 requerido para el ALB público
  }

  egress {
    description = "Trafico al backend en el puerto de la app"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = { Name = "${var.project_name}-${var.environment}-alb-sg", Environment = var.environment }
}

resource "aws_lb" "main" {
  #checkov:skip=CKV_AWS_91: Los logs de acceso requieren un bucket S3 dedicado; fuera del alcance del demo
  #checkov:skip=CKV2_AWS_20: Sin certificado TLS en ambiente de demo; se añadiría con ACM en prod
  name                       = "${var.project_name}-${var.environment}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = var.public_subnet_ids
  enable_deletion_protection = var.environment == "prod"
  drop_invalid_header_fields = true

  tags = { Name = "${var.project_name}-${var.environment}-alb", Environment = var.environment }
}

resource "aws_lb_target_group" "app" {
  #checkov:skip=CKV_AWS_378: HTTP interno entre ALB y ECS en red privada; TLS termina en el ALB
  name        = "${var.project_name}-${var.environment}-tg"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = { Name = "${var.project_name}-${var.environment}-tg", Environment = var.environment }
}

resource "aws_lb_listener" "http" {
  #checkov:skip=CKV_AWS_2: Sin certificado TLS en ambiente de demo; se añadiría con ACM en prod
  #checkov:skip=CKV_AWS_103: Listener HTTP puro en demo; TLS >= 1.2 se configura con HTTPS listener
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
