data "aws_ami" "server" {
  most_recent = true
  owners      = [var.ami_owner]
  filter {
    name   = "name"
    values = [var.server_ami_image]
  }
}

resource "aws_key_pair" "server" {
  key_name   = var.server_function
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "server_host" {
  name   = "${var.server_function}_sg"
  vpc_id = var.vpc_id

  tags = {
    Name   = "${var.server_function}/sg"
    Author = var.author
  }
}
