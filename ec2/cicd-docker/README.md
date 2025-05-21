# Hướng dẫn triển khai ứng dụng Go lên AWS bằng CI/CD

## Mục lục
1. [Yêu cầu hệ thống](#yêu-cầu-hệ-thống)
2. [Cấu trúc dự án](#cấu-trúc-dự-án)
3. [Cấu hình Docker](#cấu-hình-docker)
4. [Cấu hình GitHub Actions](#cấu-hình-github-actions)
5. [Cấu hình AWS](#cấu-hình-aws)
6. [Triển khai](#triển-khai)
7. [Kiểm tra](#kiểm-tra)
8. [Xử lý sự cố](#xử-lý-sự-cố)

## Yêu cầu hệ thống

### Công cụ cần thiết
- Go 1.21 trở lên
- Docker
- Git
- AWS CLI
- Terraform (tùy chọn)

### Tài khoản cần thiết
- GitHub account
- Docker Hub account
- AWS account

## Cấu trúc dự án

```
.
├── .github/
│   └── workflows/
│       └── deploy.yml
├── Dockerfile
├── go.mod
├── go.sum
├── main.go
└── README.md
```

## Cấu hình Docker

### Dockerfile
```dockerfile
# Build stage
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# Final stage
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/main .
EXPOSE 8080
CMD ["./main"]
```

### Build và test Docker image locally
```bash
# Build image
docker build -t your-username/go-app:latest .

# Test locally
docker run -p 8080:8080 your-username/go-app:latest
```

## Cấu hình GitHub Actions

### Secrets cần thiết
1. `DOCKER_USERNAME`: Username Docker Hub
2. `DOCKER_PASSWORD`: Password Docker Hub
3. `EC2_HOST`: IP hoặc hostname của EC2 instance
4. `SSH_PRIVATE_KEY`: Private key để SSH vào EC2

### Workflow file (.github/workflows/deploy.yml)
```yaml
name: CI/CD for Go Application

on:
  push:
    branches:
      - main

env:
  DOCKER_IMAGE: your-username/go-app
  CONTAINER_NAME: go-app
  PORT: 8080

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Setup Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Build and Push Docker Image
        run: |
          docker build -t ${{ env.DOCKER_IMAGE }}:latest .
          docker push ${{ env.DOCKER_IMAGE }}:latest

      - name: Deploy to EC2
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.EC2_HOST }}
          username: ec2-user
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          script: |
            # Install Docker
            sudo dnf update -y
            sudo dnf install -y docker
            sudo systemctl enable docker
            sudo systemctl start docker
            sudo usermod -aG docker ec2-user

            # Install Nginx
            sudo dnf install -y nginx
            sudo systemctl enable nginx
            sudo systemctl start nginx

            # Configure Nginx
            sudo tee /etc/nginx/conf.d/go-app.conf << 'EOL'
            server {
                listen 80;
                server_name _;
                location / {
                    proxy_pass http://localhost:8080;
                    proxy_http_version 1.1;
                    proxy_set_header Upgrade $http_upgrade;
                    proxy_set_header Connection 'upgrade';
                    proxy_set_header Host $host;
                    proxy_cache_bypass $http_upgrade;
                }
            }
            EOL

            # Reload Nginx
            sudo nginx -t && sudo systemctl reload nginx

            # Deploy Docker container
            sudo docker pull ${{ env.DOCKER_IMAGE }}:latest
            sudo docker stop ${{ env.CONTAINER_NAME }} || true
            sudo docker rm ${{ env.CONTAINER_NAME }} || true
            sudo docker run --name ${{ env.CONTAINER_NAME }} \
              -p ${{ env.PORT }}:${{ env.PORT }} \
              --restart unless-stopped \
              -d ${{ env.DOCKER_IMAGE }}:latest
```

## Cấu hình AWS

### EC2 Instance
1. Launch EC2 instance với Amazon Linux 2023
2. Security Group cần mở các port:
   - 22 (SSH)
   - 80 (HTTP)
   - 8080 (Application)

### IAM Role
1. Tạo IAM role cho EC2 với các policy:
   - AmazonEC2ContainerRegistryReadOnly
   - AmazonSSMManagedInstanceCore

## Triển khai

1. Push code lên GitHub repository
2. GitHub Actions sẽ tự động:
   - Build Docker image
   - Push lên Docker Hub
   - Deploy lên EC2 instance

## Kiểm tra

1. Kiểm tra ứng dụng:
```bash
curl http://your-ec2-ip
```

2. Kiểm tra logs:
```bash
# Docker logs
docker logs go-app

# Nginx logs
sudo tail -f /var/log/nginx/error.log
```

3. Kiểm tra trạng thái:
```bash
# Docker container
docker ps

# Nginx
sudo systemctl status nginx
```

## Xử lý sự cố

### 1. Docker không chạy
```bash
# Kiểm tra Docker service
sudo systemctl status docker

# Khởi động lại Docker
sudo systemctl restart docker
```

### 2. Nginx không chạy
```bash
# Kiểm tra cấu hình
sudo nginx -t

# Khởi động lại Nginx
sudo systemctl restart nginx
```

### 3. Port đã được sử dụng
```bash
# Kiểm tra process đang sử dụng port
sudo lsof -i :8080

# Kill process
sudo kill -9 <PID>
```

### 4. Container không start
```bash
# Kiểm tra logs
docker logs go-app

# Kiểm tra cấu hình container
docker inspect go-app
```

## Bảo mật

1. Luôn sử dụng HTTPS trong production
2. Cấu hình Security Groups chặt chẽ
3. Sử dụng AWS Secrets Manager cho sensitive data
4. Regular security updates
5. Monitor logs và alerts

## Monitoring

1. AWS CloudWatch cho monitoring
2. Set up alerts cho:
   - CPU usage
   - Memory usage
   - Disk space
   - Application errors

## Backup

1. Regular backup của:
   - Application data
   - Configuration files
   - Database (nếu có)

## Scaling

1. Auto Scaling Group cho EC2
2. Load Balancer
3. Multiple availability zones

## Maintenance

1. Regular updates:
   - Security patches
   - Docker images
   - Go dependencies
2. Log rotation
3. Disk cleanup
4. Performance monitoring
