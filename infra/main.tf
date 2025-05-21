# Cấu hình provider AWS và region
provider "aws" {
  region = var.region
}

# --- VPC ---
# Tạo VPC chính cho toàn bộ infrastructure
# VPC này sẽ chứa tất cả các tài nguyên mạng khác
# enable_dns_support và enable_dns_hostnames cho phép sử dụng DNS trong VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# --- Internet Gateway ---
# Tạo Internet Gateway để cho phép các tài nguyên trong VPC kết nối với internet
# Internet Gateway là thành phần cần thiết để các instance trong public subnet có thể truy cập internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

# --- Public Subnet (EC2) ---
# Tạo public subnet để chứa các EC2 instance
# map_public_ip_on_launch = true: tự động gán public IP cho các instance được tạo trong subnet này
# availability_zone: chọn zone a trong region được chỉ định
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# --- Private Subnet (RDS) ---
# Tạo private subnet để chứa RDS instance
# map_public_ip_on_launch = false: không gán public IP cho các instance trong subnet này
# Điều này giúp tăng tính bảo mật cho database
resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr
  map_public_ip_on_launch = false
  availability_zone       = "${var.region}a"

  tags = {
    Name = "${var.project_name}-private-subnet-a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr_b
  map_public_ip_on_launch = false
  availability_zone       = "${var.region}b"

  tags = {
    Name = "${var.project_name}-private-subnet-b"
  }
}

resource "aws_subnet" "private_c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr_c
  map_public_ip_on_launch = false
  availability_zone       = "${var.region}c"

  tags = {
    Name = "${var.project_name}-private-subnet-c"
  }
}

# --- Route Table for Public Subnet ---
# Tạo route table cho public subnet
# Route table này định nghĩa luồng traffic cho các instance trong public subnet
# Route 0.0.0.0/0 -> IGW: cho phép tất cả traffic ra internet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Liên kết route table với public subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# --- Security Group: EC2 (App) ---
# Tạo security group cho EC2 instance
# Security group này định nghĩa các rule cho phép traffic vào/ra EC2 instance
# Cho phép:
# - SSH (port 22) từ IP cụ thể
# - HTTP (port 80) từ mọi nơi
# - HTTPS (port 443) từ mọi nơi
# - Tất cả traffic đi ra (egress)
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Allow HTTP/HTTPS/SSH"
  vpc_id      = aws_vpc.main.id

  # Chỉ cho phép SSH từ bastion host
  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  # Cho phép HTTP/HTTPS từ mọi nơi (vì EC2 sẽ chạy web app)
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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
    Name = "${var.project_name}-ec2-sg"
  }
}

# --- Security Group: RDS (PostgreSQL) ---
# Tạo security group cho RDS instance
# Security group này chỉ cho phép kết nối PostgreSQL (port 5432) từ các instance trong EC2 security group
# Điều này đảm bảo chỉ ứng dụng chạy trên EC2 mới có thể kết nối đến database
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Allow PostgreSQL access from bastion and dev machine"
  vpc_id      = aws_vpc.main.id

  # Chỉ cho phép kết nối từ bastion host
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  # Cho phép kết nối từ IP dev (nếu cần truy cập trực tiếp từ máy local)
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.dev_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}
