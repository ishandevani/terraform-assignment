# Create Security Group
resource "aws_security_group" "web_sg" {
  name        = "terraform-web-security"
  description = "Allow SSH, Flask and Express"

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Express frontend
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Flask backend
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Terraform-Web-SG"
  }
}

# Create EC2 Instance
resource "aws_instance" "web_server" {
  ami           = "ami-0dc0718b8dd0dedd8"
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [
    aws_security_group.web_sg.id
  ]

  user_data_replace_on_change = true

  user_data = templatefile("user_data.sh", {
    flask_app          = base64encode(file("flask-backend/app.py"))
    flask_requirements = base64encode(file("flask-backend/requirements.txt"))
    express_server     = base64encode(file("express-frontend/server.js"))
    express_package    = base64encode(file("express-frontend/package.json"))
    html_file          = base64encode(file("express-frontend/public/index.html"))
    css_file           = base64encode(file("express-frontend/public/style.css"))
  })

  tags = {
    Name = "Flask-Express-Server"
  }
}
