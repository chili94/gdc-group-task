output "client_vpc" {
  value       = aws_vpc.customer_vpc.id
  description = "VPC for customer"
}

output "client_subnet_a" {
  value       = aws_subnet.customer_public_subnet_1.id
  description = "Public-a subnet for EKS"
}

output "client_subnet_b" {
  value       = aws_subnet.customer_public_subnet_2.id
  description = "Public-b subnet for EKS"
}
