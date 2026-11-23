#!/bin/bash

# Stop the script if any command fails
set -e

# Save script output and errors in a log file
exec > /var/log/user-data.log 2>&1

echo "Starting EC2 application deployment..."

# Use the official Ubuntu mirror
sed -i 's|http://ap-south-1.ec2.archive.ubuntu.com/ubuntu|http://archive.ubuntu.com/ubuntu|g' /etc/apt/sources.list.d/ubuntu.sources

# Update Ubuntu packages
apt-get update -o Acquire::Retries=5

# Install Python and Node.js
apt-get install -y python3 python3-pip python3-venv nodejs npm

# Create application directories
mkdir -p /home/ubuntu/flask-backend
mkdir -p /home/ubuntu/express-frontend/public

# Copy Flask files
echo "${flask_app}" | base64 -d > /home/ubuntu/flask-backend/app.py
echo "${flask_requirements}" | base64 -d > /home/ubuntu/flask-backend/requirements.txt

# Copy Express files
echo "${express_server}" | base64 -d > /home/ubuntu/express-frontend/server.js
echo "${express_package}" | base64 -d > /home/ubuntu/express-frontend/package.json

# Copy HTML and CSS files
echo "${html_file}" | base64 -d > /home/ubuntu/express-frontend/public/index.html
echo "${css_file}" | base64 -d > /home/ubuntu/express-frontend/public/style.css

# Give ownership to Ubuntu user
chown -R ubuntu:ubuntu /home/ubuntu/flask-backend
chown -R ubuntu:ubuntu /home/ubuntu/express-frontend

# Install Flask dependencies
cd /home/ubuntu/flask-backend

python3 -m venv venv

./venv/bin/pip install -r requirements.txt
./venv/bin/pip install gunicorn

# Install Express dependencies
cd /home/ubuntu/express-frontend

npm install

# Create Flask service
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

# Create Express service
cat > /etc/systemd/system/express.service <<'EOF'
[Unit]
Description=Express Frontend
After=network.target flask.service

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/express-frontend
Environment=BACKEND_URL=http://127.0.0.1:5000
ExecStart=/usr/bin/node server.js
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Start both applications
systemctl daemon-reload

systemctl enable flask
systemctl enable express

systemctl start flask
systemctl start express

echo "Flask and Express applications started successfully!"
