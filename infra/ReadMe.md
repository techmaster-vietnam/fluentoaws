# Mục tiêu và Nhiệm vụ của Infrastructure

File `main.tf` định nghĩa cấu trúc cơ sở hạ tầng AWS cho ứng dụng, bao gồm các thành phần chính sau:

## 1. VPC và Networking
- Tạo VPC chính với DNS support và hostnames
- Thiết lập Internet Gateway để kết nối với internet
- Tạo hai loại subnet:
  - Public subnet: Cho Bastion Host EC2 instance, có thể truy cập internet
  - Private subnet: Cho RDS database và App EC2 instance, không thể truy cập trực tiếp từ internet
- Cấu hình Route Table cho public subnet để định tuyến traffic

## 2. Security Groups
- Bastion Host Security Group:
  - Cho phép SSH (port 22), HTTP (port 80), HTTPS (port 443) từ mọi nơi
  - Cho phép tất cả traffic đi ra
- EC2 App Security Group:
  - Cho phép SSH (port 22) chỉ từ Bastion Host
  - Cho phép HTTP (port 80) và HTTPS (port 443) từ mọi nơi
  - Cho phép tất cả traffic đi ra
- RDS Security Group:
  - Cho phép PostgreSQL (port 5432) từ Bastion Host
  - Cho phép kết nối PostgreSQL từ IP developer (cho pgAdmin)

## 3. Mục tiêu Bảo mật
- Tách biệt mạng public và private
- Sử dụng Bastion Host làm điểm truy cập duy nhất vào private subnet
- Giới hạn truy cập database chỉ từ Bastion Host và developer
- Kiểm soát chặt chẽ các kết nối SSH thông qua Bastion Host

## 4. Khả năng Mở rộng
- Cấu trúc được thiết kế để dễ dàng thêm các thành phần mới
- Sử dụng biến để dễ dàng tùy chỉnh cấu hình

# Infrastructure as Code với Terraform

## Cấu trúc thư mục
```
infra/
├── main.tf           # Cấu hình VPC, Subnet, Security Group
├── bastion.tf        # Cấu hình Bastion Host
├── rds.tf            # Cấu hình RDS PostgreSQL
├── variables.tf      # Định nghĩa các biến
├── outputs.tf        # Định nghĩa các output
└── terraform.tfvars  # Giá trị của các biến
```

## Cài đặt và Triển khai

1. Cài đặt Terraform
2. Cấu hình AWS credentials
3. Khởi tạo Terraform:
```bash
terraform init
```
4. Xem trước các thay đổi:
```bash
terraform plan
```
5. Triển khai infrastructure:
```bash
terraform apply
```

## Kết nối PostgreSQL

### 1. Thông tin kết nối
Sau khi triển khai thành công, bạn có thể lấy thông tin kết nối bằng lệnh:
```bash
terraform output
```

### 2. Kết nối qua Bastion Host (SSH Tunnel)
```bash
# Tạo SSH tunnel
ssh -i ~/.ssh/aws_key -L 5432:<rds_endpoint>:5432 ec2-user@<bastion_public_ip>

# Kết nối PostgreSQL qua tunnel
psql "postgresql://<username>:<password>@localhost:5432/<database>"
```

### 3. Kết nối bằng pgAdmin
1. Tạo SSH tunnel như hướng dẫn trên
2. Mở pgAdmin
3. Click chuột phải vào Servers > Create > Server
4. Trong tab General:
   - Name: Polylang RDS
5. Trong tab Connection:
   - Host: localhost
   - Port: 5432
   - Database: <database>
   - Username: <username>

### 4. Kết nối từ ứng dụng
```go
import (
    "database/sql"
    _ "github.com/lib/pq"
)

dsn := "postgresql://<username>:<password>@<endpoint>/<database>?sslmode=require"
db, err := sql.Open("postgres", dsn)
```

### Lưu ý quan trọng:
1. Đảm bảo IP của máy của bạn (`dev_ip` trong terraform.tfvars) đã được cấu hình trong Security Group
2. Kết nối chỉ được phép từ:
   - Bastion Host
   - IP của máy dev được cấu hình
3. RDS instance nằm trong private subnet, không thể truy cập trực tiếp từ internet
4. Sử dụng SSL khi kết nối (thêm `?sslmode=require` vào connection string)
5. Luôn sử dụng SSH tunnel thông qua Bastion Host để kết nối an toàn

## Xóa infrastructure
```bash
terraform destroy
```

