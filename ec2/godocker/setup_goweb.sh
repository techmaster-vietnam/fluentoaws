#!/bin/bash

# Tạo thư mục cho ứng dụng
sudo mkdir -p /var/goweb

# Di chuyển binary file
sudo mv /tmp/goweb /var/goweb/
sudo chmod +x /var/goweb/goweb

# Tạo systemd service file
cat << EOF | sudo tee /etc/systemd/system/goweb.service
[Unit]
Description=Go Web Application
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/var/goweb
ExecStart=/var/goweb/goweb
Restart=always
RestartSec=5
StandardOutput=append:/var/log/goweb.log
StandardError=append:/var/log/goweb.error.log

[Install]
WantedBy=multi-user.target
EOF

# Tạo log files
sudo touch /var/log/goweb.log /var/log/goweb.error.log
sudo chmod 644 /var/log/goweb.log /var/log/goweb.error.log

# Reload systemd và khởi động service
sudo systemctl daemon-reload
sudo systemctl enable goweb
sudo systemctl start goweb

# Đợi service khởi động
sleep 10

# Kiểm tra trạng thái service và thoát ngay lập tức
if sudo systemctl is-active goweb; then
    echo "Service is active"
    # In ra log để debug
    echo "=== Application Log ==="
    sudo tail -n 20 /var/log/goweb.log
    echo "=== Error Log ==="
    sudo tail -n 20 /var/log/goweb.error.log
    exit 0
else
    echo "Service failed to start"
    # In ra log để debug
    echo "=== Application Log ==="
    sudo tail -n 20 /var/log/goweb.log
    echo "=== Error Log ==="
    sudo tail -n 20 /var/log/goweb.error.log
    exit 1
fi 