variable "vpc_id" {
  type        = string
  description = "Virtual Private Cloud identier"
}

variable "availability_zones" {
  type = list(string)
}

variable "author" {
  type = string
}

variable "env" {
  type = string
}
