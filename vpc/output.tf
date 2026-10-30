output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs keyed by availability zone."
  value       = { for key, subnet in aws_subnet.public : key => subnet.id }
}

output "private_subnet_ids" {
  description = "Private subnet IDs keyed by availability zone."
  value       = { for key, subnet in aws_subnet.private : key => subnet.id }
}

output "nat_gateway_id" {
  description = "ID of the single NAT gateway."
  value       = aws_nat_gateway.this.id
}
