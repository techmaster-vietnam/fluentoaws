#!/bin/bash

# Exit on error
set -e

# Configuration
APP_NAME="go-web"
APP_USER="ec2-user"
APP_DIR="/home/${APP_USER}/app"
APP_PORT=8080
NGINX_CONF="/etc/nginx/conf.d/${APP_NAME}.conf"
BACKUP_DIR="${APP_DIR}/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Check if required arguments are provided
if [ -z "$1" ]; then
    echo "Usage: $0 <host>"
    exit 1
fi

HOST=$1

# Function to execute remote commands
remote_exec() {
    ssh -i ~/.ssh/go-web-key -o StrictHostKeyChecking=accept-new ${APP_USER}@${HOST} "$1"
}

# Function to copy files
remote_copy() {
    scp -i ~/.ssh/go-web-key -o StrictHostKeyChecking=accept-new "$1" ${APP_USER}@${HOST}:"$2"
}

echo "🚀 Starting deployment to ${HOST}..."

# Create application directory and set permissions
echo "📁 Creating application directory..."
remote_exec "sudo mkdir -p ${APP_DIR} ${BACKUP_DIR} && sudo chown -R ${APP_USER}:${APP_USER} ${APP_DIR} && sudo chmod 755 ${APP_DIR}"

# Backup and remove existing application if exists
echo "📦 Checking for existing application..."
remote_exec "bash -s" << EOF
    if [ -f "${APP_DIR}/myapp" ]; then
        echo "Found existing application, creating backup..."
        cp "${APP_DIR}/myapp" "${BACKUP_DIR}/myapp_${TIMESTAMP}"
        cp "${APP_DIR}/app.log" "${BACKUP_DIR}/app.log_${TIMESTAMP}" 2>/dev/null || true
        echo "Backup created at ${BACKUP_DIR}/myapp_${TIMESTAMP}"
        
        # Stop the application if running
        pkill myapp || true
        sleep 2
        
        # Remove the old binary
        rm -f "${APP_DIR}/myapp"
    fi
EOF

# Copy application binary
echo "📦 Copying new application binary..."
remote_copy "./myapp" "${APP_DIR}/myapp"

# Configure Nginx
echo "🔧 Configuring Nginx..."
remote_exec "sudo tee ${NGINX_CONF} << 'NGINX'
server {
    listen 80;
    server_name _;
    
    location / {
        proxy_pass http://127.0.0.1:${APP_PORT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
NGINX"

# Test and reload Nginx
echo "🔄 Testing and reloading Nginx..."
remote_exec "sudo nginx -t && sudo systemctl reload nginx"

# Deploy application
echo "🚀 Deploying application..."
remote_exec "bash -s" << EOF
    # Set proper permissions
    sudo chown ${APP_USER}:${APP_USER} ${APP_DIR}/myapp
    chmod +x ${APP_DIR}/myapp

    # Start new application
    cd ${APP_DIR}
    nohup ./myapp > app.log 2>&1 &
    sleep 2  # Wait for process to start

    # Verify application is running
    if ! pgrep myapp > /dev/null; then
        echo "Error: Application failed to start"
        exit 1
    fi
EOF

# Check application status
echo "🔍 Checking application status..."
remote_exec "ps aux | grep myapp | grep -v grep"

echo "✅ Deployment completed successfully!"
echo "📝 Application logs:"
remote_exec "tail -n 20 ${APP_DIR}/app.log"

# List backups
echo "📚 Available backups:"
remote_exec "ls -lh ${BACKUP_DIR}" 