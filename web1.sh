
# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: This script must be run as root."
    exit 1
fi

# Install Nginx using dnf
dnf install nginx -y

# Enable and start Nginx
systemctl enable nginx
systemctl start nginx
 
# Clear Nginx HTML directory
rm -rf /usr/share/nginx/html/*

# Download and extract web content
curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip
cd /usr/share/nginx/html || exit
unzip -o /tmp/web.zip

# Configure Nginx with custom settings
cat <<EOL > /etc/nginx/default.d/roboshop.conf
proxy_http_version 1.1;

location /images/ {
  expires 5s;
  root   /usr/share/nginx/html;
  try_files \$uri /images/placeholder.jpg;
}

location /api/catalogue/ { proxy_pass http://catalogue.jagadishdaws.online:8080/; }
location /api/user/ { proxy_pass http://user.jagadishdaws.online:8080/; }
location /api/cart/ { proxy_pass http://cart.jagadishdaws.online:8080/; }
location /api/shipping/ { proxy_pass http://localhost:8080/; }
location /api/payment/ { proxy_pass http://localhost:8080/; }

location /health {
  stub_status on;
  access_log off;
}
EOL


# Restart Nginx to apply changes
systemctl restart nginx

echo "Nginx configuration completed successfully."