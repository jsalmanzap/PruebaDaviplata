output "alb_url" {
  description = "URL pública del ALB — usado por el pipeline para smoke tests"
  value       = "http://${module.alb.alb_dns_name}"
}

output "ecr_repository_url" {
  description = "URL del repositorio ECR — usado por el pipeline para hacer push de imágenes"
  value       = module.ecr.repository_url
}

output "ecs_cluster_name" {
  description = "Nombre del cluster ECS — usado por el pipeline de deploy"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Nombre del servicio ECS — usado por el pipeline de deploy"
  value       = module.ecs.service_name
}

output "log_group_name" {
  description = "Nombre del log group de CloudWatch"
  value       = module.ecs.log_group_name
}
