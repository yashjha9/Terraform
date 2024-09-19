
# VPC project using Auto Scaling Group (ELB + ASG)

To Improve resiliency, deploying servers in two Availability zones, by using an Auto Scaling Group and Application Load Balancer.
For additional security, deploying servers in private subnets.
These servers will receive request from LB. The servers can connect to the internet by using NAT Gateway.

Bastion Sever will be created in the Public subnet.

Other 2 servers will be created in Private subnets using Auto Scaling Group and these servers will be attached to Load Balancer as a Target Group.



