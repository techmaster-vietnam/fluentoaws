variable "region" {
  default = "ap-southeast-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.2.0/24"
}

variable "private_subnet_cidr_b" {
  default = "10.0.3.0/24"
}

variable "private_subnet_cidr_c" {
  default = "10.0.4.0/24"
}

variable "project_name" {
  default = "golang-app"
}


variable "ami_id" {
  description = "Amazon Machine Image ID"
  type        = string
  default     = "ami-0afc7fe9be84307e4"  # Amazon Linux 2023 tại Singapore
}

variable "dev_ip" {
  description = "IP address của máy dev để kết nối trực tiếp với RDS"
  type        = string
}

# RDS Variables
variable "rds_instance_class" {
  description = "Instance class for RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Allocated storage for RDS in GB"
  type        = number
  default     = 20
}

variable "rds_db_name" {
  description = "Name of the database to create"
  type        = string
  default     = "polylang"
}

variable "rds_username" {
  description = "Username for the master DB user"
  type        = string
  default     = "root"
}

variable "rds_password" {
  description = "Password for the master DB user"
  type        = string
  sensitive   = true
}

variable "key_name" {
  description = "Name of the SSH key pair to use for the bastion host"
  type        = string
}
