#  Confirm the bastion host allows for ssh access:
ssh -i ubuntu@bastion_ip

# Create a tunnel for ssh entry into the application instance. The structure for tunnel creation is:
```ssh -L TARGET_PORT:TARGET_INSTANCE_PRIVATE_IP:22  ubuntu@bastion_ip```
n/b: the arguments after -L is a non-positional flag so, it can be written before or after ubuntu@bastion_ip
An example of a created tunnel is:
ssh ubuntu@bastion_ip -L 4000:instance_private_ip:22

Here is what the above those:
- The tunnel makes the localhost an ip/dns for access (ubuntu@localhost)
- The tunnel does a port binding of 4000 on the previous mentioned localhost to port 22 on the private instance ip. 
Imagine this as -p 4000:22 we do with docker

# To access the application instance you can now use:
ssh ubuntu@localhost -p 4000

docker run -p 8080:8080 -p 50000:50000 -d -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -v $(which docker):/usr/bin/docker jenkins/jenkins:2.319.3

Viola