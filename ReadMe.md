# Hướng dẫn sử dụng Terraform với AWS

## 1. Giới thiệu về Terraform

Terraform là một công cụ Infrastructure as Code (IaC) được phát triển bởi HashiCorp, cho phép bạn định nghĩa và quản lý cơ sở hạ tầng cloud một cách tự động thông qua mã nguồn.

### Ưu điểm của Terraform so với AWS CLI và AWS Console:

- **Quản lý phiên bản**: Mã nguồn Terraform có thể được quản lý bằng Git, giúp theo dõi thay đổi và rollback khi cần thiết
- **Tự động hóa**: Giảm thiểu lỗi do thao tác thủ công
- **Tái sử dụng**: Có thể tái sử dụng mã nguồn cho nhiều môi trường khác nhau
- **Nhất quán**: Đảm bảo cơ sở hạ tầng được triển khai giống nhau ở mọi môi trường
- **Tài liệu hóa**: Mã nguồn Terraform đóng vai trò như tài liệu cho cơ sở hạ tầng
- **Quản lý state**: Terraform theo dõi trạng thái của cơ sở hạ tầng, giúp quản lý thay đổi hiệu quả

## 2. Cài đặt Terraform

### Trên macOS:
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

### Trên Linux:
```bash
# Thêm HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Thêm repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Cập nhật và cài đặt
sudo apt update
sudo apt install terraform
```

## 3. Cú pháp cơ bản của Terraform

### Provider
```hcl
provider "aws" {
  region = "ap-southeast-1"
}
```

### Resource
```hcl
resource "aws_instance" "example" {
  ami           = "ami-123456"
  instance_type = "t2.micro"
}
```

### Variable
```hcl
variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t2.micro"
}
```

### Output
```hcl
output "instance_ip" {
  value = aws_instance.example.public_ip
}
```

## 4. Ví dụ thực tế

### 4.1. Tạo EC2 với Security Group cho SSH

```hcl
# Security Group cho SSH
resource "aws_security_group" "ssh_sg" {
  name        = "ssh_security_group"
  description = "Security group for SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "example" {
  ami           = "ami-123456"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ssh_sg.id]

  tags = {
    Name = "ExampleInstance"
  }
}
```

### 4.2. Tạo S3 Bucket

```hcl
# S3 Bucket
resource "aws_s3_bucket" "example" {
  bucket = "my-example-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

# Cấu hình versioning cho bucket
resource "aws_s3_bucket_versioning" "example" {
  bucket = aws_s3_bucket.example.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Cấu hình server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

## Các lệnh Terraform cơ bản

```bash
# Khởi tạo Terraform
terraform init

# Xem trước các thay đổi
terraform plan

# Áp dụng các thay đổi
terraform apply

# Xóa cơ sở hạ tầng
terraform destroy
```
