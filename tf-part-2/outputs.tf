output "flask_instance_id" {
  value = aws_instance.flask_server.id
}

output "flask_public_ip" {
  value = aws_instance.flask_server.public_ip
}

output "flask_private_ip" {
  value = aws_instance.flask_server.private_ip
}

output "flask_backend_url" {
  value = "http://${aws_instance.flask_server.public_ip}:5000"
}

output "express_instance_id" {
  value = aws_instance.express_server.id
}

output "express_public_ip" {
  value = aws_instance.express_server.public_ip
}

output "express_frontend_url" {
  value = "http://${aws_instance.express_server.public_ip}:3000"
}
