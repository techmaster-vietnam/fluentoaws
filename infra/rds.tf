# --- RDS Subnet Group ---
# Tạo subnet group cho RDS
# RDS cần ít nhất 2 subnet trong các AZ khác nhau để đảm bảo tính sẵn sàng cao
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project_name}-rds-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name = "${var.project_name}-rds-subnet-group"
  }
}

# --- RDS Parameter Group ---
# Tạo parameter group để cấu hình PostgreSQL
resource "aws_db_parameter_group" "rds_parameter_group" {
  family = "postgres17"
  name   = "${var.project_name}-rds-parameter-group"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  tags = {
    Name = "${var.project_name}-rds-parameter-group"
  }
}

# --- RDS Instance ---
# Tạo RDS instance chạy PostgreSQL
resource "aws_db_instance" "rds" {
  identifier           = "${var.project_name}-rds"
  engine              = "postgres"
  engine_version      = "17.5"
  instance_class      = "db.t3.micro"  # Free tier eligible
  allocated_storage   = 20             # Free tier eligible
  storage_type        = "gp2"
  
  db_name             = var.rds_db_name
  username            = var.rds_username
  password            = var.rds_password
  
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  parameter_group_name   = aws_db_parameter_group.rds_parameter_group.name
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"
  
  multi_az               = false
  publicly_accessible    = false
  skip_final_snapshot    = true
  
  tags = {
    Name = "${var.project_name}-rds"
  }
} 