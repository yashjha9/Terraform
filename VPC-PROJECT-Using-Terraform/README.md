
# Creating VPC and Securing App within VPC

VPC stands for Virtual Private Cloud.
It introduces concept of Private cloud in the world of Public cloud.




## Workflow of VPC

- DevOps or AWS DevOps engineers builds the VPC.
- The size of VPC depends on IPAddress range (CIDR block).
- Once applications are deployed inside the VM’s in VPC, VM’s are assigned with IP’s.
- Now to access the application in VM’s, user need to go thru Internet Gateway 
- Without Gateway, no one can access VPC.
- Public subnet is the one that a user access first inside the VPC.
- Public subnet is connected to the internet, by using the Internet Gateway.
- LoadBalancer Will be in Public subnet, LB is the one through which request gets forwarded depending on load.
- For public subnet there will be a router, in AWS terms called as route table. This table defines how request should go to the application.
- LB sends request depending upon target group.
- From Internet gateway > public subnet > request goes to LB, LB is assigned with public subnet > from LB, create target group for the app which needs to be accessed.
- If request from LB to Private subnet needs to go, but LB is not aware how to go through that. To overcome this, for private subnet create the route table.
- Once request from user reaches VM’s or EC2 instances, there can be something that blocks the request, called as Security Group.
- Security Group Provides Security at Instance level.
- NAT Gateway Provides Security at Subnet level.

## Overview of VPC Project

- VPC will have Public and Private Subnets.
- Each Public subnet will have NAT Gateway.
- Application will be deployed in the Private Subnet.
- With help of NAT Gateway, Application will access the internet.
- Here taking 2 instances, but in real time, for High Availability Auto scaling is used with Max, Min, desired capacity set.
- Create 2 instances, One instance in Public Subnet and Second Instance in Private Subnet.
- As Instance created in Private subnet, it will not have Public IP.
- The Instance which will be created in Public subnet will act as  Bastion Host, this Bastion Host will be used to connect and deploy application into the Private instance.
- There are multiple advantages of using Bastion host (or Jump server), instead of directly connecting to the server, user can connect through bastion, so that there will be proper login mechanisms, can do proper auditing like who is accessing private subnet. Bunch of rules can be configured in Bastion host where traffic actually go to app through Bastion host.
- Create Target group 
- Create LB and attach the Private instance as a Target group to the LoadBalancer. 

## Steps to execute the Project using AWS Console:
- In AWS Console, search for VPC.
- Create VPC. Click on VPC Only, Provide Name for VPC.
- Provide IPV4 CIDR range, lets give 10.0.0.0/16 and click on Create VPC.
- Create Internet Gateway and attach IGW to the newly created VPC.
- Create 2 Public and Private Subnets in different Availability zone, by going to the Subnet option and select the VPC which is newly created.
- Create 2 Route Tables, One for Public Subnet and Other for Private Subnet.
- Associate Public Subnet with the Public Route Table and Private Subnet with the Private Route Table.
- Create Route entry for IGW inside the Public Route table with destination cidr block 0.0.0.0/0, just by going inside the Public Route table and click on edit routes to make the entry for IGW.
- Create the NAT Gateway in Public Subnet and Allocate elastic IP to NAT gateway.
- Make a Route entry for NAT Gateway inside the Private Subnet with destination cidr 0.0.0.0/0
- Create Security group by selecting new VPC and open the ports for SSH (Port 22), HTTP (Port 80).
-  Connect to Bastion Host and copy the .pem file inside the Bastion Host.
- Change the permission of .pem file,
```bash
    chmod 400 <.pem file name>
```
- Use this .pem file to connect to Private instance,
```bash
    ssh -i <.pem file name> ubuntu@<private IP of Private Instance>
```
- With help of NAT Gateway, Private Instance will have Internet access. As NAT gateway is attached to Public subnet which has route entry of IGW, and Private subnet to which Private instance is connected to has route entry of NAT Gateway, by this NAT gateway will provide the Internet access to the Private Instance.
- Deploy the Application, lets say apache2, inside the Private instance.
- Now, Create a Target group and attach this Private instance as a Target group.
- Create LoadBalancer and select Public Subnets in 2 AZ and make sure that LB should always be Internet Facing and select target group to which Private instance is attached and configure Listeners and rules for LoadBalancer.
-  Once LB gets created, copy the DNS of LoadBalancer and Hit on Browser. Basic Ubuntu page will be accessible on the Browser.






