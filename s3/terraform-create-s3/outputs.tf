output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.static_website.id
}

output "bucket_website_endpoint" {
  description = "The website endpoint URL"
  value       = aws_s3_bucket_website_configuration.static_website.website_endpoint
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.static_website.arn
}