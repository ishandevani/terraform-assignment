#!/bin/bash

set -e

# Save installation output in a log file
exec > /var/log/user-data.log 2>&1

echo "Starting Flask Backend installation..."

# Update Ubuntu mirror
sed -i 's|http://ap-south-1.ec2.archive.ubuntu.com/ubuntu|http://archive.ubuntu.com/ubuntu|g' /etc/apt/sources.list.d/ubuntu.sources

# Update packages
apt-get update -o Acquire::Retries=5

# Install Python
apt-get install -y python3 python3-pip python3-venv

# Create Flask application directory
mkdir -p /home/ubuntu/flask-backend

# Copy Flask application files
echo "${flask_app}" | base64 -d > /home/ubuntu/flask-backend/app.py
echo "${flask_requirements}" | base64 -d > /home/ubuntu/flask-backend/requirements.txt

# Set ownership
chown -R ubuntu:ubuntu /home/ubuntu/flask-backend

# Create Python virtual environment
cd /home/ubuntu/flask-backend
python3 -m venv venv

# Install Flask dependencies
./venv/bin/pip install -r requirements.txt
./venv/bin/pip install gunicorn

# Create Flask systemd service
cat > /etc/systemd/system/flask.service <<'EOF'
[Unit]
Description=Flask Backend
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/flask-backend
ExecStart=/home/ubuntu/flask-backend/venv/bin/gunicorn --bind 0.0.0.0:5000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Start Flask service
systemctl daemon-reload
systemctl enable flask
systemctl start flask

echo "Flask Backend installation completed!"
