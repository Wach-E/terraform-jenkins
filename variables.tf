variable "author" {
  type    = string
  default = "wach"
}

variable "vpc_cidr_block" {
  type = string
}

variable "env" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "ami_bastion_image" {
  type        = string
  description = "Amazon Machine Image used to create bastion host"
}

variable "bastion_instance_type" {
  type        = string
  description = "Instance type for EC2 server"
}

variable "bastion_ami_owner" {
  type        = string
  description = "Owmer of bastion ami"
}

variable "public_key_path" {
  type        = string
  description = "Location of public key"
}

variable "ip_address_range" {
  type        = string
  description = "IP range to allow SSH connection"
}

variable "ami_jenkins_image" {
  type        = string
  description = "Amazon Machine Image used to create bastion host"
}

variable "jenkins_instance_type" {
  type        = string
  description = "Instance type for EC2 server"
}

variable "jenkins_ami_owner" {
  type        = string
  description = "Owmer of bastion ami"
}

variable "jenkins_port" {
  type = number
}


# variable "private_key_path" {
#   type        = string
#   description = "(optional) describe your variable"
# }