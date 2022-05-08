variable "server_function" {
  type        = string
  description = "Function of EC2 server"
}

variable "ami_owner" {
  type        = string
  description = "owner of machine image"
}

variable "server_ami_image" {
  type        = string
  description = "Amazon Machine Image used to create bastion host"
}

variable "vpc_id" {
  type        = string
  description = "Virtual Private Cloud identier"
}

variable "author" {
  type = string
}

variable "public_key_path" {
  type        = string
  description = "Location of public key"
}

