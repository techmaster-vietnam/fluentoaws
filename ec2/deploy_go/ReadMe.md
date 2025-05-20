# Dự án Deploy Go Web Application lên AWS EC2

## 1. Mục tiêu của dự án
Dự án này nhằm tự động hóa quá trình triển khai một ứng dụng web Go lên AWS EC2 instance sử dụng Terraform. Dự án bao gồm việc cấu hình infrastructure, build ứng dụng, và tự động deploy lên server với các tính năng như:
- Tự động tạo và cấu hình EC2 instance
- Cấu hình security groups cho SSH và HTTP/HTTPS
- Build ứng dụng Go và deploy lên server
- Cấu hình systemd service để chạy ứng dụng
- Tự động khởi động và monitoring ứng dụng

## 2. Cấu trúc thư mục và file
```
├── goweb/                    # Thư mục chứa mã nguồn ứng dụng Go
│   ├── go.mod                # File quản lý dependencies của Go
│   ├── go.sum                # File checksum của dependencies
│   ├── goweb                 # Binary file của ứng dụng sau khi build
│   ├── main.go               # File mã nguồn chính của ứng dụng
│   └── Makefile              # File cấu hình build automation
├── main.tf                   # File cấu hình chính của Terraform
├── outputs.tf                # File định nghĩa output của Terraform
├── setup_goweb.sh            # Script cấu hình và khởi động ứng dụng trên EC2
└── variables.tf              # File định nghĩa biến cho Terraform
```

## 3. Quy trình triển khai
File `setup_goweb.sh` được gọi từ `main.tf` thông qua resource `null_resource` "build_and_deploy". Quy trình triển khai diễn ra như sau:

1. Terraform build ứng dụng Go bằng lệnh `make aws` trong thư mục `goweb`
2. Copy binary file `goweb` lên EC2 instance vào thư mục `/tmp`
3. Copy script `setup_goweb.sh` lên EC2 instance
4. Thực thi script `setup_goweb.sh` với quyền sudo để:
   - Tạo thư mục `/var/goweb`
   - Di chuyển binary file vào thư mục này
   - Cấu hình systemd service
   - Khởi động service và kiểm tra trạng thái