# Hướng dẫn triển khai EC2 Instance với Terraform

## 1. Mục đích của code
Code này được sử dụng để tự động hóa việc tạo và cấu hình một EC2 instance trên AWS với các thành phần sau:
- Security Group cho phép SSH access
- Key pair để SSH vào instance
- EC2 instance với Amazon Linux 2023
- Các cấu hình cơ bản như region, instance type

## 2. Các bước thực hiện

### Yêu cầu tiên quyết
- Đã cài đặt Terraform
- Đã cài đặt AWS CLI và cấu hình credentials
- Có sẵn SSH key pair tại `~/.ssh/id_rsa.pub`

### Các bước thực hiện
1. Khởi tạo Terraform:
```bash
terraform init
```

2. Xem trước các thay đổi:
```bash
terraform plan
```

3. Áp dụng cấu hình:
```bash
terraform apply
```
Sau khi chạy thành công, bạn sẽ thấy output hiển thị instance_id và public_ip. Sử dụng public_ip để SSH vào instance:

```bash
ssh -i ~/.ssh/id_rsa ec2-user@<public_ip>
```

Lưu ý:
- Sử dụng user `ec2-user` vì đây là user mặc định cho Amazon Linux 2023
- Đảm bảo file private key (~/.ssh/id_rsa) có quyền truy cập phù hợp:
```bash
chmod 400 ~/.ssh/id_rsa
```
4. Khi muốn xóa tài nguyên:
```bash
terraform destroy
```

## 3. Giải thích các file Terraform

### main.tf
File chính chứa các resource cần tạo:
- Security Group cho SSH
- Key pair
- EC2 instance

### variables.tf
Định nghĩa các biến được sử dụng trong main.tf:
- aws_region: Region để triển khai (mặc định: ap-southeast-1)
- ami_id: ID của Amazon Machine Image (mặc định: Amazon Linux 2023 tại Singapore)

### outputs.tf
Định nghĩa các giá trị output sau khi triển khai:
- instance_id: ID của EC2 instance
- public_ip: Public IP của instance
- ssh_command: SSH command đã được định dạng sẵn để kết nối vào instance

## 4. Chi tiết các khối lệnh

### Trong main.tf

#### Provider AWS
```hcl
provider "aws" {
  region = var.aws_region
}
```
- Cấu hình provider AWS và region

#### Security Group
```hcl
# Kiểm tra security group đã tồn tại
data "aws_security_group" "existing_ssh_sg" {
  name   = "ssh_security_group"
  filter {
    name   = "group-name"
    values = ["ssh_security_group"]
  }
}

# Tạo security group mới nếu chưa tồn tại
resource "aws_security_group" "ssh_sg" {
  count       = length(data.aws_security_group.existing_ssh_sg.id) == 0 ? 1 : 0
  name        = "ssh_security_group"
  description = "Security group for SSH access"
  ...
}
```
- Kiểm tra xem security group đã tồn tại chưa thông qua data source
- Chỉ tạo security group mới nếu chưa tồn tại (sử dụng count)
- Tạo security group cho phép SSH (port 22)
- Cho phép tất cả outbound traffic
- Có lifecycle rule create_before_destroy để đảm bảo không bị gián đoạn khi cập nhật

#### Key Pair
```hcl
resource "aws_key_pair" "ssh_key" {
  key_name   = "cuong_ssh_key"
  public_key = file("~/.ssh/id_rsa.pub")
}
```
- Tạo key pair từ public key có sẵn
- Sử dụng để SSH vào instance

#### EC2 Instance
```hcl
resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  ...
}
```
- Tạo EC2 instance với Amazon Linux 2023
- Sử dụng t2.micro instance type
- Gắn security group và key pair đã tạo

### Trong variables.tf
- Định nghĩa biến aws_region với giá trị mặc định là ap-southeast-1
- Định nghĩa biến ami_id với giá trị mặc định là Amazon Linux 2023 AMI

### Trong outputs.tf
- Output instance_id để lấy ID của instance
- Output public_ip để lấy địa chỉ IP public của instance
- Output ssh_command để lấy lệnh SSH đã được định dạng sẵn để kết nối vào instance

