output "public_subnet_id" {
  description = "The ID of the public subnet where the instance will be launched"
  value       = aws_subnet.public.id
}

output "vpc_id" {
  description = "The ID of the VPC where the security group will be created"
  value       = aws_vpc.terraform_vpc.id
}