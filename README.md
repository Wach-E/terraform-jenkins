# terraform-jenkins
![jenkins-infra-setup](terraform-jenkins.jpg)

This repo contains the configuration files for setting up a Jenkins server with docker on an ec2 server using Terraform.

## Pre-requisites
- [A baked image with docker](https://github.com/Wach-E/jenkins-server-with-packer)


Step 1: Clone this repository
```
git clone https://github.com/Wach-E/terraform-jenkins.git
```

Step 2: Rename the example-terraform.tfvars to terraform.tfvars. 
N/B: Replace the the contents in the terraform.tfvars

Step 3: Initialize terraform providers and modules
```
terraform init
```

Step 4: Modify the format of your config files and validate them
```
terraform fmt
terraform validate
```

Step 4: Apply terraform configuration
```
terraform apply
```

Step 5: Obtain the IP of the Loadbalancer and access the Jenkins application

## TODO: 
- Resolve issues connected to this repository
- Suggest better solutions to fit the Well-architected framework (e.g  using an autoscaling group with scaling policies in cloud watch and so much more)

Let's connect: [My profile](https://github.com/Wach-E)

![Alt](https://repobeats.axiom.co/api/embed/7a017b1d38004f8c5238532996f2ae134a24701c.svg "Repobeats analytics image")


