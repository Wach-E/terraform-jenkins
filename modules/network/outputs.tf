output "required_public_subnet" {
  value = element(aws_subnet.public_subnets.*.id, 0)
}

output "required_private_subnet" {
  value = element(aws_subnet.private_subnets.*.id, 0)
}

output "aws_public_subnets" {
  value = aws_subnet.public_subnets
}
