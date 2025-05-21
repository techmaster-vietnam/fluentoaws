output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private_a.id
}

output "private_subnet_b_id" {
  value = aws_subnet.private_b.id
}

output "ec2_security_group_id" {
  value = aws_security_group.ec2_sg.id
}

output "rds_security_group_id" {
  value = aws_security_group.rds_sg.id
}

# RDS Outputs
output "rds_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.rds.endpoint
}

output "rds_port" {
  description = "The port the RDS instance is listening on"
  value       = aws_db_instance.rds.port
}

output "rds_database_name" {
  description = "The name of the database"
  value       = aws_db_instance.rds.db_name
}

output "rds_username" {
  description = "The master username for the database"
  value       = aws_db_instance.rds.username
  sensitive   = true
}

output "rds_connection_info" {
  description = "Thông tin kết nối RDS qua bastion host"
  value = {
    rds_endpoint = aws_db_instance.rds.endpoint
    rds_port     = aws_db_instance.rds.port
    rds_database = aws_db_instance.rds.db_name
    rds_username = aws_db_instance.rds.username
    bastion_host = aws_instance.bastion.public_ip
    bastion_user = "ec2-user"
  }
  sensitive = true
}

output "pgadmin_connection_guide" {
  description = "Hướng dẫn cấu hình kết nối trong pgAdmin"
  value = <<-EOT
    Để kết nối đến RDS qua bastion host trong pgAdmin:

    1. Tạo SSH tunnel:
       - Host: ${aws_instance.bastion.public_ip}
       - Port: 22
       - Username: ec2-user
       - Private key: Sử dụng key pair đã tạo

    2. Cấu hình kết nối PostgreSQL:
       - Host: ${aws_db_instance.rds.endpoint}
       - Port: 5432
       - Database: ${aws_db_instance.rds.db_name}
       - Username: ${aws_db_instance.rds.username}
       - Password: [Sử dụng mật khẩu RDS]
  EOT
}

output "bastion_public_ip" {
  description = "Public IP của bastion host"
  value       = aws_instance.bastion.public_ip
}
