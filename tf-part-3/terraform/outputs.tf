output "alb_dns_name" {
  description = "Public URL of the Application Load Balancer"
  value       = "http://${aws_lb.main.dns_name}"
}

output "flask_ecr_url" {
  description = "ECR Repository URL for Flask"
  value       = aws_ecr_repository.flask.repository_url
}

output "express_ecr_url" {
  description = "ECR Repository URL for Express"
  value       = aws_ecr_repository.express.repository_url
}
