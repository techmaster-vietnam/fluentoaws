# Cấu hình provider AWS với region được định nghĩa trong biến
provider "aws" {
  region = var.aws_region
}

# Tìm kiếm security group đã tồn tại có tên "ssh_security_group"
# Nếu không tìm thấy, sẽ tạo mới security group
data "aws_security_group" "existing_ssh_sg" {
  name   = "ssh_security_group"
  filter {
    name   = "group-name"
    values = ["ssh_security_group"]
  }
}

# Tạo security group mới nếu chưa tồn tại
# Security group này cho phép:
# - SSH (port 22)
# - HTTP (port 80)
# - HTTPS (port 443)
# - Tất cả outbound traffic
resource "aws_security_group" "ssh_sg" {
  count       = length(data.aws_security_group.existing_ssh_sg.id) == 0 ? 1 : 0
  name        = "ssh_security_group"
  description = "Security group for SSH, HTTP and HTTPS access"

  # Cho phép SSH từ bất kỳ đâu
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Cho phép HTTP từ bất kỳ đâu
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Cho phép tất cả outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh_security_group"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Tạo key pair AWS từ public key local
# Public key được đọc từ file ~/.ssh/aws_key.pub
resource "aws_key_pair" "ssh_key" {
  key_name   = "cuong_ssh_key"
  public_key = file("~/.ssh/aws_key.pub")
}



# Resource để build và deploy ứng dụng
# Bao gồm các bước:
# 1. Build ứng dụng Go
# 2. Copy binary file lên EC2
# 3. Cấu hình và chạy ứng dụng
resource "null_resource" "build_and_deploy" {
  triggers = {
    always_run = "${timestamp()}"
  }

  depends_on = [aws_instance.example]

  # Build ứng dụng Go
  provisioner "local-exec" {
    command = "cd ${path.module}/goweb && make aws"
    on_failure = fail
  }

  # Copy binary file lên EC2
  provisioner "file" {
    source      = "${path.module}/goweb/goweb"
    destination = "/tmp/goweb"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/aws_key")
      host        = aws_instance.example.public_ip
    }
  }


  # Cấu hình và chạy ứng dụng trên EC2
  provisioner "file" {
    source      = "${path.module}/setup_goweb.sh"
    destination = "/tmp/setup_goweb.sh"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/aws_key")
      host        = aws_instance.example.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup_goweb.sh",
      "sudo /tmp/setup_goweb.sh",
      # Kiểm tra xem service có đang chạy không
      "if sudo systemctl is-active --quiet goweb; then echo 'Service is running'; else exit 1; fi",
      # Kiểm tra xem ứng dụng có lắng nghe trên port không
      "sleep 10",
      "if netstat -tuln | grep LISTEN | grep -E ':80|:8080|:3000'; then echo 'Application is listening on port'; else echo 'Warning: No listening port found'; fi"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/aws_key")
      host        = aws_instance.example.public_ip
    }
  }
}

# Tạo EC2 instance
# Sử dụng:
# - AMI được định nghĩa trong biến
# - Instance type t2.micro
# - Security group đã tạo ở trên
# - Key pair đã tạo ở trên
resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [
    length(data.aws_security_group.existing_ssh_sg.id) == 0 ? aws_security_group.ssh_sg[0].id : data.aws_security_group.existing_ssh_sg.id
  ]

  tags = {
    Name = "CuongEC2Instance"
  }
}