# Ứng Dụng Web Go với Pipeline CI/CD trên EC2

Đây là một dự án mẫu về cách triển khai tự động một ứng dụng web Go lên máy chủ EC2 của AWS thông qua GitHub Actions.

## Tổng Quan Dự Án

Dự án bao gồm các thành phần chính sau:
- Ứng dụng web viết bằng Go, chạy trên cổng 8080
- Nginx làm reverse proxy (cổng nối tiếp)
- Hệ thống CI/CD tự động sử dụng GitHub Actions
- Script triển khai cho EC2

## Yêu Cầu Hệ Thống

Trước khi bắt đầu, bạn cần chuẩn bị:

1. **Máy chủ EC2**:
   - Chạy hệ điều hành Amazon Linux hoặc tương tự
   - Có đủ RAM và CPU để chạy ứng dụng
   - Có kết nối internet ổn định

2. **Cài đặt trên EC2**:
   - Nginx (web server)
   - User `ec2-user` (user mặc định của Amazon Linux)
   - Các quyền cần thiết để chạy ứng dụng

3. **Cấu hình GitHub**:
   - Tài khoản GitHub
   - Repository để lưu trữ code
   - Quyền truy cập vào GitHub Actions

4. **SSH Key**:
   - Cặp khóa SSH để kết nối với EC2
   - Private key sẽ được lưu trong GitHub Secrets

## Cấu Hình GitHub Secrets

Để đảm bảo an toàn, bạn cần thêm các thông tin nhạy cảm vào GitHub Secrets:

1. `EC2_SSH_KEY`:
   - Đây là private key SSH của bạn
   - Dùng để kết nối với EC2
   - Được mã hóa và lưu trữ an toàn trong GitHub

2. `EC2_HOST`:
   - Địa chỉ IP hoặc tên miền của máy chủ EC2
   - Ví dụ: `ec2-xx-xx-xx-xx.compute-1.amazonaws.com`

## Cấu Trúc Dự Án

```
.
├── .github/                    # Thư mục chứa cấu hình GitHub
│   └── workflows/             # Chứa các file cấu hình CI/CD
│       └── deploy.yml        # File cấu hình GitHub Actions
├── scripts/                   # Thư mục chứa các script
│   └── deploy.sh            # Script triển khai lên EC2
└── main.go                  # File code chính của ứng dụng Go
```

## Cấu Trúc Thư Mục Trên EC2

```
/home/ec2-user/              # Thư mục home của user ec2-user
└── app/                    # Thư mục chứa ứng dụng
    ├── myapp              # File thực thi của ứng dụng
    ├── app.log           # File log của ứng dụng
    └── backups/          # Thư mục chứa các bản sao lưu
```

## Quy Trình CI/CD

Pipeline được kích hoạt khi có code mới được đẩy lên nhánh `main`:

1. **Quá Trình Build**:
   - Lấy code mới nhất từ repository
   - Cài đặt Go phiên bản 1.21
   - Biên dịch ứng dụng thành file thực thi

2. **Quá Trình Triển Khai**:
   - Kết nối SSH vào máy chủ EC2
   - Tạo cấu trúc thư mục cần thiết
   - Sao lưu phiên bản cũ (nếu có)
   - Triển khai phiên bản mới
   - Cấu hình Nginx
   - Khởi động ứng dụng

## Cấu Hình Nginx

Nginx được cấu hình làm reverse proxy với các tính năng:
- Lắng nghe kết nối trên cổng 80 (HTTP)
- Chuyển tiếp request đến ứng dụng Go trên cổng 8080
- Cấu hình các header bảo mật
- Xử lý các kết nối WebSocket
- Cấu hình cache và proxy

## Quy Trình Triển Khai

1. **Đẩy Code**:
   - Đẩy code mới lên nhánh `main`
   - GitHub Actions tự động kích hoạt pipeline

2. **Quá Trình Tự Động**:
   - Build ứng dụng Go
   - Kết nối SSH vào EC2
   - Tạo bản sao lưu
   - Triển khai phiên bản mới
   - Cấu hình Nginx
   - Khởi động ứng dụng

## Giám Sát và Bảo Trì

### Kiểm Tra Trạng Thái Ứng Dụng

```bash
# Kiểm tra ứng dụng có đang chạy không
ps aux | grep myapp

# Xem log của ứng dụng
tail -f /home/ec2-user/app/app.log

# Xem log của Nginx
sudo tail -f /var/log/nginx/access.log  # Log truy cập
sudo tail -f /var/log/nginx/error.log   # Log lỗi
```

### Quản Lý Bản Sao Lưu

- Tự động tạo bản sao lưu trước mỗi lần triển khai
- Lưu trong thư mục `/home/ec2-user/app/backups/`
- Tên file theo định dạng: `myapp_YYYYMMDD_HHMMSS`

## Bảo Mật

1. **Bảo Mật SSH**:
   - Khóa SSH được lưu trong GitHub Secrets
   - Kiểm tra host key nghiêm ngặt
   - Giới hạn quyền theo user `ec2-user`

2. **Bảo Mật Ứng Dụng**:
   - Ứng dụng chạy dưới user `ec2-user`
   - Nginx được cấu hình với các header bảo mật
   - Phân quyền file phù hợp

3. **Bảo Mật Mạng**:
   - Ứng dụng chỉ có thể truy cập qua Nginx
   - Cổng nội bộ (8080) không được mở trực tiếp
   - Nginx xử lý các kết nối bên ngoài qua cổng 80

## Xử Lý Sự Cố

1. **Lỗi Triển Khai**:
   - Kiểm tra log của GitHub Actions
   - Xác minh kết nối EC2
   - Kiểm tra quyền truy cập

2. **Lỗi Ứng Dụng**:
   - Kiểm tra log ứng dụng
   - Xác minh cấu hình Nginx
   - Kiểm tra cổng có sẵn sàng không

3. **Lỗi Nginx**:
   - Kiểm tra cấu hình Nginx
   - Xem log Nginx
   - Test cấu hình Nginx

## Đóng Góp

1. Fork repository
2. Tạo nhánh mới cho tính năng
3. Commit các thay đổi
4. Đẩy lên nhánh
5. Tạo Pull Request

## Giấy Phép

[Thêm thông tin giấy phép của bạn vào đây]
