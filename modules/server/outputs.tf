output "ami_server_id" {
  value = data.aws_ami.server.id
}

output "keypair_name" {
  value = aws_key_pair.server.key_name
}

output "security_group_id" {
  value = aws_security_group.server_host.id
}
