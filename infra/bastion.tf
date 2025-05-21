# --- Bastion Host Security Group ---
resource "aws_security_group" "bastion_sg" {
  name        = "${var.project_name}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = [22, 80, 443]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  
  # Cho phép outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-bastion-sg"
  }
}

# Tạo key pair AWS từ public key local để SSH vào instance
resource "aws_key_pair" "ssh_key" {
  key_name   = "cuong_ssh_key"
  public_key = file("~/.ssh/aws_key.pub")
}


# --- Bastion Host EC2 Instance ---
resource "aws_instance" "bastion" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id     # Sửa từ public_a thành public

  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name      = aws_key_pair.ssh_key.key_name

  tags = {
    Name = "${var.project_name}-bastion"
  }
} 