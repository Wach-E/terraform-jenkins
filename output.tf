output "bastion-public-ip" {
  value = aws_instance.bastion.public_ip
}

output "bastion-private-ip" {
  value = aws_instance.bastion.private_ip
}

output "jenkins-private-ip" {
  value = aws_instance.jenkins_master.private_ip
}

output "jenkins-master-elb" {
  value = aws_lb.jenkins_master.dns_name
}
