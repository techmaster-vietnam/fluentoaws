# Cấu hình provider AWS với region được định nghĩa trong biến
provider "aws" {
  region = var.aws_region
}

# Tìm kiếm security group đã tồn tại có tên "ssh_security_group"
data "aws_security_group" "existing_ssh_sg" {
  name   = "ssh_security_group"
  filter {
    name   = "group-name"
    values = ["ssh_security_group"]
  }
}

# Tạo security group mới nếu chưa tồn tại
# Security group này cho phép:
# - SSH (port 22) từ mọi nơi
# - HTTP (port 80) từ mọi nơi
# - Tất cả traffic đi ra ngoài
resource "aws_security_group" "ssh_sg" {
  count       = length(data.aws_security_group.existing_ssh_sg.id) == 0 ? 1 : 0
  name        = "ssh_security_group"
  description = "Security group for SSH and HTTP access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

# Tạo key pair AWS từ public key local để SSH vào instance
resource "aws_key_pair" "ssh_key" {
  key_name   = "cuong_ssh_key"
  public_key = file("~/.ssh/aws_key.pub")
}

# Tạo EC2 instance với các cấu hình:
# - AMI ID từ biến
# - Instance type t2.micro
# - Sử dụng key pair đã tạo
# - Gắn security group
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

  # Copy file index.html từ local lên instance
  provisioner "file" {
    source      = "index.html"
    destination = "/tmp/index.html"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/aws_key")
      host        = self.public_ip
      timeout     = "5m"
    }
  }

  # Thực thi các lệnh trên instance sau khi tạo:
  # 1. Cài đặt nginx
  # 2. Enable và start nginx service
  # 3. Copy file index.html vào thư mục web root
  # 4. Set quyền sở hữu file cho nginx
  # 5. Restart nginx để áp dụng thay đổi
  provisioner "remote-exec" {
    inline = [
      "sudo dnf install -y nginx",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
      "sudo mv /tmp/index.html /usr/share/nginx/html/index.html",
      "sudo chown nginx:nginx /usr/share/nginx/html/index.html",
      "sudo systemctl restart nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/aws_key")
      host        = self.public_ip
      timeout     = "5m"
    }
  }
}