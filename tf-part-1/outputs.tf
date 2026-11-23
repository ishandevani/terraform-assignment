# Display EC2 Instance ID
output "instance_id" {
  value = aws_instance.web_server.id
}

# Display EC2 Public IP
output "public_ip" {
  value = aws_instance.web_server.public_ip
}

# Express Frontend URL
output "frontend_url" {
  value = "http://${aws_instance.web_server.public_ip}:3000"
}

# Flask Backend URL
output "backend_url" {
  value = "http://${aws_instance.web_server.public_ip}:5000"
}
