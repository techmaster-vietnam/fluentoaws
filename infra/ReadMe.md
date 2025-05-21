# Mục tiêu và Nhiệm vụ của Infrastructure

File `main.tf` định nghĩa cấu trúc cơ sở hạ tầng AWS cho ứng dụng, bao gồm các thành phần chính sau:

## 1. VPC và Networking
- Tạo VPC chính với DNS support và hostnames
- Thiết lập Internet Gateway để kết nối với internet
- Tạo hai loại subnet:
  - Public subnet: Cho EC2 instances, có thể truy cập internet
  - Private subnet: Cho RDS database, không thể truy cập trực tiếp từ internet
- Cấu hình Route Table cho public subnet để định tuyến traffic

## 2. Security Groups
- EC2 Security Group:
  - Cho phép SSH (port 22) từ IP developer
  - Cho phép HTTP (port 80) và HTTPS (port 443) từ mọi nơi
  - Cho phép tất cả traffic đi ra
- RDS Security Group:
  - Cho phép PostgreSQL (port 5432) từ EC2 instances
  - Cho phép kết nối PostgreSQL từ IP developer (cho pgAdmin)

## 3. Mục tiêu Bảo mật
- Tách biệt mạng public và private
- Giới hạn truy cập database chỉ từ EC2 và developer
- Kiểm soát chặt chẽ các kết nối SSH

## 4. Khả năng Mở rộng
- Cấu trúc được thiết kế để dễ dàng thêm các thành phần mới
- Sử dụng biến để dễ dàng tùy chỉnh cấu hình

ec2_security_group_id = "sg-0312d733c2c2beb2c"
private_subnet_id = "subnet-073edc8a15731621f"
public_subnet_id = "subnet-0c75420ab1fb91f60"
rds_security_group_id = "sg-077cd5f32a4ff0f30"
vpc_id = "vpc-09dfb7f53438d7546"

# Infrastructure as Code với Terraform

## Cấu trúc thư mục
```
infra/
├── main.tf           # Cấu hình VPC, Subnet, Security Group
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

### 2. Kết nối bằng psql
```bash
psql "postgresql://<username>:<password>@<endpoint>/<database>"
```

### 3. Kết nối bằng pgAdmin
1. Mở pgAdmin
2. Click chuột phải vào Servers > Create > Server
3. Trong tab General:
   - Name: Polylang RDS
4. Trong tab Connection:
   - Host: <endpoint>
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
   - EC2 instances trong cùng VPC
   - IP của máy dev được cấu hình
3. RDS instance nằm trong private subnet, không thể truy cập trực tiếp từ internet
4. Sử dụng SSL khi kết nối (thêm `?sslmode=require` vào connection string)

## Xóa infrastructure
```bash
terraform destroy
```

