# Cấu hình Terraform cho Web Server trên AWS EC2

File `main.tf` này là một cấu hình Terraform để triển khai một web server trên AWS EC2 với các mục tiêu chính sau:

## 1. Cấu hình Security
- Tạo hoặc sử dụng security group có sẵn tên "ssh_security_group"
- Cho phép kết nối SSH (port 22) và HTTP (port 80) từ mọi nơi
- Cho phép tất cả traffic đi ra ngoài

## 2. Cấu hình SSH Access
- Tạo key pair AWS từ public key local để có thể SSH vào instance
- Sử dụng key pair này để kết nối với instance

## 3. Triển khai EC2 Instance
- Tạo một EC2 instance với AMI ID được định nghĩa trong biến
- Sử dụng instance type t2.micro
- Gắn security group đã tạo
- Đặt tên instance là "CuongEC2Instance"

## 4. Cài đặt và Cấu hình Web Server
- Copy file `index.html` từ local lên instance
- Cài đặt và cấu hình Nginx web server
- Copy file `index.html` vào thư mục web root của Nginx
- Set quyền sở hữu file cho Nginx
- Khởi động và enable Nginx service

## Mục tiêu
Mục tiêu cuối cùng là tạo một web server có thể truy cập công khai thông qua HTTP, hiển thị nội dung từ file `index.html` đã được cấu hình.
