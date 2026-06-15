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

output "vpc_endpoint_ids" {
  description = "Map of VPC endpoint IDs by service name. Empty when VPC endpoints are disabled."
  value = merge(
    { for service, endpoint in aws_vpc_endpoint.gateway : service => endpoint.id },
    { for service, endpoint in aws_vpc_endpoint.interface : service => endpoint.id }
  )
}

output "gateway_vpc_endpoint_ids" {
  description = "Map of gateway VPC endpoint IDs by service name."
  value       = { for service, endpoint in aws_vpc_endpoint.gateway : service => endpoint.id }
}

output "interface_vpc_endpoint_ids" {
  description = "Map of interface VPC endpoint IDs by service name."
  value       = { for service, endpoint in aws_vpc_endpoint.interface : service => endpoint.id }
}

output "vpc_endpoint_security_group_id" {
  description = "Security group ID used by interface VPC endpoints, when created."
  value       = try(aws_security_group.vpc_endpoints[0].id, null)
}
