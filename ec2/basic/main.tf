provider "aws" {
  region = var.aws_region
}

# Try to fetch existing security group
data "aws_security_group" "existing_ssh_sg" {
  name   = "ssh_security_group"
  filter {
    name   = "group-name"
    values = ["ssh_security_group"]
  }
}

# Create security group only if it doesn't exist
resource "aws_security_group" "ssh_sg" {
  count       = length(data.aws_security_group.existing_ssh_sg.id) == 0 ? 1 : 0
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
    create_before_destroy = true
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
  vpc_security_group_ids = [
    length(data.aws_security_group.existing_ssh_sg.id) == 0 ? aws_security_group.ssh_sg[0].id : data.aws_security_group.existing_ssh_sg.id
  ]

  tags = {
    Name = "CuongEC2Instance"
  }
}