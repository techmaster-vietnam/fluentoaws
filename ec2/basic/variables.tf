variable "aws_region" {
  description = "Region to deploy EC2"
  type        = string
  default     = "ap-southeast-1"  # Singapore
}

variable "ami_id" {
  description = "Amazon Machine Image ID"
  type        = string
  default     = "ami-0afc7fe9be84307e4"  # Amazon Linux 2023 tại Singapore
}