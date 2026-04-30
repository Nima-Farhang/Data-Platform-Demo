output "vpc_id" {
  description = "ID of the platform VPC."
  value       = aws_vpc.platform.id
}

output "vpc_arn" {
  description = "ARN of the platform VPC."
  value       = aws_vpc.platform.arn
}

output "vpc_cidr_block" {
  description = "CIDR block assigned to the platform VPC."
  value       = aws_vpc.platform.cidr_block
}

output "public_subnet_id" {
  description = "ID of the public subnet."
  value       = aws_subnet.public.id
}

output "public_subnet_arn" {
  description = "ARN of the public subnet."
  value       = aws_subnet.public.arn
}

output "private_subnet_id" {
  description = "ID of the private subnet."
  value       = aws_subnet.private.id
}

output "private_subnet_arn" {
  description = "ARN of the private subnet."
  value       = aws_subnet.private.arn
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway attached to the platform VPC."
  value       = aws_internet_gateway.platform.id
}

output "internet_gateway_arn" {
  description = "ARN of the Internet Gateway attached to the platform VPC."
  value       = aws_internet_gateway.platform.arn
}
