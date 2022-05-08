vpc_cidr_block     = ""
env                = ""
availability_zones = ["", "", ""]
public_key_path    = "/path/to/public_key/file/"
# private_key_path   = "/path/to/private_key/file/"
ip_address_range   = "address to allow through bastion host"
# Bastion
ami_bastion_image     = "ubuntu-*-*-amd64-server-*"
bastion_instance_type = "instance type for bastion host"
bastion_ami_owner     = "owner of ami image"
# Jenkins
jenkins_port          = 8080
ami_jenkins_image     = "custom jenkins ami backed with packer(https://github.com/Wach-E/jenkins-server-with-packer)"
jenkins_instance_type = "instance type for jenkins"
jenkins_ami_owner     = "self"
