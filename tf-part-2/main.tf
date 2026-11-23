# Create VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Part2-VPC"
  }
}

# Create Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Part2-Public-Subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Part2-Internet-Gateway"
  }
}

# Create Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Part2-Public-Route-Table"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group for Express Frontend
resource "aws_security_group" "express_sg" {
  name        = "part2-express-sg"
  description = "Allow SSH and Express frontend traffic"
  vpc_id      = aws_vpc.main_vpc.id

  # Allow SSH from my IP
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # Allow public access to Express
  ingress {
    description = "Express frontend access"
    from_port   = 3000
    to_port     = 3000
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
    Name = "Part2-Express-SG"
  }
}

# Security Group for Flask Backend
resource "aws_security_group" "flask_sg" {
  name        = "part2-flask-sg"
  description = "Allow SSH, Flask and Express communication"
  vpc_id      = aws_vpc.main_vpc.id

  # Allow SSH from my IP
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # Allow Flask access from the internet
  ingress {
    description = "Public Flask access"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Express EC2 to communicate with Flask EC2
  ingress {
    description     = "Express to Flask communication"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.express_sg.id]
  }

  # Allow outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Part2-Flask-SG"
  }
}

# Create Flask Backend EC2 Instance
resource "aws_instance" "flask_server" {
  ami           = "ami-0dc0718b8dd0dedd8"
  instance_type = var.instance_type
  key_name      = var.key_name

  subnet_id = aws_subnet.public_subnet.id

  vpc_security_group_ids = [
    aws_security_group.flask_sg.id
  ]

  associate_public_ip_address = true

  user_data = templatefile("flask-user-data.sh", {
    flask_app          = base64encode(file("flask-backend/app.py"))
    flask_requirements = base64encode(file("flask-backend/requirements.txt"))
  })

  user_data_replace_on_change = true

  tags = {
    Name = "Part2-Flask-Backend"
  }
}

# Create Express Frontend EC2 Instance
resource "aws_instance" "express_server" {
  ami           = "ami-0dc0718b8dd0dedd8"
  instance_type = var.instance_type
  key_name      = var.key_name

  subnet_id = aws_subnet.public_subnet.id

  vpc_security_group_ids = [
    aws_security_group.express_sg.id
  ]

  associate_public_ip_address = true

  user_data = templatefile("express-user-data.sh", {
    express_server  = base64encode(file("express-frontend/server.js"))
    express_package = base64encode(file("express-frontend/package.json"))
    html_file       = base64encode(file("express-frontend/public/index.html"))
    css_file        = base64encode(file("express-frontend/public/style.css"))

    flask_private_ip = aws_instance.flask_server.private_ip
  })

  user_data_replace_on_change = true

  depends_on = [
    aws_instance.flask_server
  ]

  tags = {
    Name = "Part2-Express-Frontend"
  }
}
