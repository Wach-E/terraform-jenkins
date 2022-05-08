terraform {
  required_version = ">= 1.1.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.3.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

/******************************************************************************
* VPC
*******************************************************************************/

/**
* AWS Virtual Private Cloud (VPC) lets you provision a logically isolated
*section of the AWS cloud where you can launch AWS resources in a virtual network
*that you can define. You have complete control over your virtual networking environment, 
*including a selection of your own IP address range, creation of subnets, 
* and configuration of route tables and network gateways
*/

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.env}_${var.author}/vpc"
  }
}

module "network" {
  source = "./modules/network"

  vpc_id = aws_vpc.vpc.id
  #   subnets_count      = var.subnets_count
  availability_zones = var.availability_zones
  author             = var.author
  env                = var.env
}

# Bastion host setup
module "bastion" {
  source = "./modules/server"

  vpc_id           = aws_vpc.vpc.id
  server_function  = "bastion_host"
  ami_owner        = var.bastion_ami_owner
  server_ami_image = var.ami_bastion_image
  author           = var.author
  public_key_path  = var.public_key_path
}

locals {
  ssh_port     = 22
  http_port    = 80
  any_port     = 0
  tcp_protocol = "tcp"
  any_protocol = "-1"
  all_ips      = "0.0.0.0/0"
}

resource "aws_instance" "bastion" {
  ami                         = module.bastion.ami_server_id
  instance_type               = var.bastion_instance_type
  key_name                    = module.bastion.keypair_name
  vpc_security_group_ids      = [module.bastion.security_group_id]
  subnet_id                   = module.network.required_public_subnet
  associate_public_ip_address = true

  tags = {
    Name   = "bastion_host"
    Author = var.author
  }
}

resource "aws_security_group_rule" "allow_connection_ssh" {
  type              = "ingress"
  security_group_id = module.bastion.security_group_id

  description = "Allow SSH connection from selected IPs"
  from_port   = local.ssh_port
  to_port     = local.ssh_port
  protocol    = local.tcp_protocol
  cidr_blocks = [var.ip_address_range]
}

resource "aws_security_group_rule" "allow_connection_egress_bastion" {
  type              = "egress"
  security_group_id = module.bastion.security_group_id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = [local.all_ips]
}

# Jenkins Master setup
module "jenkins" {
  source = "./modules/server"

  vpc_id           = aws_vpc.vpc.id
  server_function  = "jenkins"
  ami_owner        = var.jenkins_ami_owner
  server_ami_image = var.ami_jenkins_image
  author           = var.author
  public_key_path  = var.public_key_path
}

resource "aws_instance" "jenkins_master" {
  ami                         = module.jenkins.ami_server_id
  instance_type               = var.jenkins_instance_type
  key_name                    = module.jenkins.keypair_name
  vpc_security_group_ids      = [module.jenkins.security_group_id]
  subnet_id                   = module.network.required_private_subnet
  associate_public_ip_address = false

  user_data = file("${path.root}/start.sh")
  # provisioner "file" {
  #   source      = "${path.root}/start.sh"
  #   destination = "/home/ubuntu/start.sh"

  #   connection {
  #     host                = aws_instance.jenkins_master.private_ip
  #     user                = "ubuntu"
  #     port                = local.ssh_port
  #     private_key = file(var.private_key_path)
  #   }
  # }

  tags = {
    Name   = "jenkins_master"
    Author = var.author
  }
}

resource "aws_security_group_rule" "allow_ssh_connection_from_bastion_to_jenkins_master" {
  type              = "ingress"
  security_group_id = module.jenkins.security_group_id

  from_port                = local.ssh_port
  to_port                  = local.ssh_port
  protocol                 = local.tcp_protocol
  source_security_group_id = module.bastion.security_group_id
}

resource "aws_security_group_rule" "allow_http_connection_from_elb_to_jenkins_master" {
  type              = "ingress"
  security_group_id = module.jenkins.security_group_id

  from_port                = var.jenkins_port
  to_port                  = var.jenkins_port
  protocol                 = local.tcp_protocol
  source_security_group_id = aws_security_group.jenkins_master_elb.id
}

resource "aws_security_group_rule" "allow_connection_egress_jenkins" {
  type              = "egress"
  security_group_id = module.jenkins.security_group_id
  from_port         = local.any_port
  to_port           = local.any_port
  protocol          = local.any_protocol
  cidr_blocks       = [local.all_ips]
}

# Elastic Load Balancer (application) setup
resource "aws_security_group" "jenkins_master_elb" {
  name   = "jenkins_master_elb"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name   = "jenkins_master/elb"
    Author = var.author
  }
}

resource "aws_security_group_rule" "allow_admin_only_access_to_elb" {
  type              = "ingress"
  security_group_id = aws_security_group.jenkins_master_elb.id

  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = [var.ip_address_range]
}

resource "aws_security_group_rule" "allow_egress_connection_for_elb" {
  type              = "egress"
  security_group_id = aws_security_group.jenkins_master_elb.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = [local.all_ips]
}

resource "aws_lb" "jenkins_master" {
  name               = "jenkins-master-elb"
  load_balancer_type = "application"
  subnets            = [for subnet in module.network.aws_public_subnets : subnet.id]
  security_groups    = [aws_security_group.jenkins_master_elb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.jenkins_master.arn
  port              = local.http_port
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_master.arn
  }
}

resource "aws_lb_target_group" "jenkins_master" {
  name     = "jenkins-master-elb-target-group"
  port     = var.jenkins_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "jenkins_master_elb_attachment" {
  target_group_arn = aws_lb_target_group.jenkins_master.arn
  target_id        = aws_instance.jenkins_master.id
  port             = var.jenkins_port
}