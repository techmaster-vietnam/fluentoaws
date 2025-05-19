output "instance_id" {
  value = aws_instance.example.id
}

output "public_ip" {
  value = aws_instance.example.public_ip
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/aws_key ec2-user@${aws_instance.example.public_ip}"
  description = "Lệnh SSH để kết nối vào EC2 instance"
}
