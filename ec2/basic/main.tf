provider "aws" {
  region = var.aws_region
}

# Tạo security group mới
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

  tags = {
    Name = "ssh_security_group"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Tạo key pair từ public key
resource "aws_key_pair" "ssh_key" {
  key_name   = "cuong_ssh_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.ssh_sg.id]

  tags = {
    Name = "CuongEC2Instance"
  }
}
