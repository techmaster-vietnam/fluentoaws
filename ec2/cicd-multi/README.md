# Triển Khai Ứng Dụng Đa Nền Tảng với Docker và Nginx

Dự án này minh họa quy trình CI/CD để triển khai nhiều ứng dụng Go sử dụng Docker, Nginx và GitHub Actions.

## Cấu Trúc Dự Án

```
.
├── app-x/                  # Ứng dụng Go thứ nhất
│   ├── .github/
│   │   └── workflows/
│   │       └── deploy.yml  # Quy trình CI/CD cho App X
│   ├── main.go            # Mã nguồn chính
│   ├── Dockerfile         # Cấu hình Docker
│   └── go.mod             # File module Go
│
└── app-y/                  # Ứng dụng Go thứ hai
    ├── .github/
    │   └── workflows/
    │       └── deploy.yml  # Quy trình CI/CD cho App Y
    ├── main.go            # Mã nguồn chính
    ├── Dockerfile         # Cấu hình Docker
    └── go.mod             # File module Go
```

## Các Ứng Dụng

### App X
- Cổng: 8080
- Endpoint: `/x/`
- Thông điệp: "Hello from App X!"

### App Y
- Cổng: 8081
- Endpoint: `/y/`
- Thông điệp: "Hello from App Y!"

## Yêu Cầu Hệ Thống

1. **Tài Khoản GitHub**
   - Tạo hai repository: `app-x` và `app-y`
   - Thiết lập GitHub Actions secrets:
     - `DOCKER_USERNAME`: Tên đăng nhập Docker Hub
     - `DOCKER_PASSWORD`: Mật khẩu Docker Hub
     - `EC2_HOST`: IP của instance EC2
     - `SSH_PRIVATE_KEY`: Khóa SSH private để truy cập EC2

2. **Tài Khoản Docker Hub**
   - Tạo tài khoản tại [Docker Hub](https://hub.docker.com)
   - Tạo hai repository: `app-x` và `app-y`

3. **Instance EC2 (Amazon Linux 2023)**
   - Cấu hình Security Group:
     - Cho phép traffic vào cổng 80 (HTTP)
     - Cho phép traffic vào cổng 22 (SSH)
   - Yêu cầu Instance:
     - Amazon Linux 2023
     - t2.micro hoặc lớn hơn
     - Dung lượng ổ cứng tối thiểu 8GB

## Phát Triển Cục Bộ

### App X
```bash
cd app-x
go mod tidy
go run main.go
# Truy cập tại http://localhost:8080
```

### App Y
```bash
cd app-y
go mod tidy
go run main.go
# Truy cập tại http://localhost:8081
```

## Build Docker

### App X
```bash
cd app-x
docker build -t ten-dockerhub-cua-ban/app-x:latest .
docker run -p 8080:8080 ten-dockerhub-cua-ban/app-x:latest
```

### App Y
```bash
cd app-y
docker build -t ten-dockerhub-cua-ban/app-y:latest .
docker run -p 8081:8081 ten-dockerhub-cua-ban/app-y:latest
```

## Triển Khai

Quá trình triển khai được tự động hóa bằng GitHub Actions. Khi bạn push lên nhánh main của bất kỳ repository nào:

1. Workflow GitHub Actions sẽ:
   - Build Docker image
   - Push lên Docker Hub
   - Triển khai lên instance EC2

2. Trên instance EC2:
   - Docker sẽ được cài đặt (nếu chưa có)
   - Nginx sẽ được cài đặt (nếu chưa có)
   - Nginx sẽ được cấu hình để định tuyến traffic:
     - `/x/` → App X (cổng 8080)
     - `/y/` → App Y (cổng 8081)

## Truy Cập Ứng Dụng

Sau khi triển khai, bạn có thể truy cập các ứng dụng tại:
- App X: `http://ip-ec2-cua-ban/x/`
- App Y: `http://ip-ec2-cua-ban/y/`
- URL gốc (`http://ip-ec2-cua-ban/`) sẽ chuyển hướng đến App X

## Xử Lý Sự Cố

### Vấn Đề Nginx
```bash
# Kiểm tra trạng thái Nginx
sudo systemctl status nginx

# Xem log lỗi Nginx
sudo tail -f /var/log/nginx/error.log

# Kiểm tra cấu hình Nginx
sudo nginx -t

# Tải lại Nginx
sudo systemctl reload nginx
```

### Vấn Đề Docker
```bash
# Kiểm tra trạng thái Docker
sudo systemctl status docker

# Xem các container đang chạy
docker ps

# Xem log container
docker logs ten-container

# Khởi động lại Docker
sudo systemctl restart docker
```

### Vấn Đề Ứng Dụng
```bash
# Xem log ứng dụng
docker logs app-x
docker logs app-y

# Khởi động lại container
docker restart app-x
docker restart app-y
```

## Bảo Mật

1. **Bảo Mật Docker**
   - Sử dụng user không phải root trong Dockerfile
   - Cập nhật base image thường xuyên
   - Quét lỗ hổng trong image

2. **Bảo Mật Nginx**
   - Cấu hình SSL/TLS
   - Thiết lập giới hạn tốc độ
   - Bật security headers

3. **Bảo Mật EC2**
   - Sử dụng security groups
   - Cập nhật hệ thống thường xuyên
   - Giám sát log hệ thống

## Đóng Góp

1. Fork repository
2. Tạo nhánh tính năng mới
3. Commit thay đổi
4. Push lên nhánh
5. Tạo Pull Request

## Giấy Phép

Dự án này được cấp phép theo MIT License - xem file LICENSE để biết thêm chi tiết.
