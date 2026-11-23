#!/bin/bash

set -e

# Save installation output in a log file
exec > /var/log/user-data.log 2>&1

echo "Starting Express Frontend installation..."

# Update Ubuntu mirror
sed -i 's|http://ap-south-1.ec2.archive.ubuntu.com/ubuntu|http://archive.ubuntu.com/ubuntu|g' /etc/apt/sources.list.d/ubuntu.sources

# Update packages
apt-get update -o Acquire::Retries=5

# Install Node.js and npm
apt-get install -y nodejs npm

# Create Express application directories
mkdir -p /home/ubuntu/express-frontend/public

# Copy Express application files
echo "${express_server}" | base64 -d > /home/ubuntu/express-frontend/server.js
echo "${express_package}" | base64 -d > /home/ubuntu/express-frontend/package.json

# Copy HTML and CSS files
echo "${html_file}" | base64 -d > /home/ubuntu/express-frontend/public/index.html
echo "${css_file}" | base64 -d > /home/ubuntu/express-frontend/public/style.css

# Set ownership
chown -R ubuntu:ubuntu /home/ubuntu/express-frontend

# Install Express dependencies
cd /home/ubuntu/express-frontend
npm install

# Create Express systemd service
cat > /etc/systemd/system/express.service <<'EOF'
[Unit]
Description=Express Frontend
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/express-frontend
Environment="BACKEND_URL=http://${flask_private_ip}:5000"
ExecStart=/usr/bin/node server.js
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Start Express service
systemctl daemon-reload
systemctl enable express
systemctl start express

echo "Express Frontend installation completed!"
