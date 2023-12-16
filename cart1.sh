#!/bin/bash

# Check if Node.js is already installed
if ! command -v node &> /dev/null; then
    # Disable the existing Node.js module and enable version 18
    dnf module disable nodejs -y
    dnf module enable nodejs:18 -y

    # Install Node.js
    dnf install nodejs -y
fi

# Check if the 'roboshop' user already exists
if ! id -u roboshop &> /dev/null; then
    # Add application user
    useradd roboshop
fi

# Check if /app directory already exists
if [ ! -d "/app" ]; then
    # Setup app directory
    mkdir /app
fi

# Download application code if not already downloaded
if [ ! -f "/app/server.js" ]; then
    curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip
    cd /app
    unzip /tmp/cart.zip
fi

# Install application dependencies
cd /app
npm install

# Check if SystemD service is not already configured
if [ ! -f "/etc/systemd/system/cart.service" ]; then
    # Setup SystemD Cart Service
    cat <<EOF > /etc/systemd/system/cart.service
[Unit]
Description=Cart Service

[Service]
User=roboshop
Environment=REDIS_HOST=redis.jagadishdaws.online
Environment=CATALOGUE_HOST=catalogue.jagadishdaws.online
Environment=CATALOGUE_PORT=8080
ExecStart=/usr/bin/node /app/server.js
SyslogIdentifier=cart

[Install]
WantedBy=multi-user.target
EOF
fi

# Load the service
systemctl daemon-reload

# Enable and start the service
systemctl enable cart
systemctl start cart
echo "cart runned successfully"