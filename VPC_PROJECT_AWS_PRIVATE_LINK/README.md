# AWS Private Link (VPC EndPoint Service)

AWS Private link also called as VPC Endpoint Service.
AWS has designed this service to provide the connectivity between the VPC’s and Various AWS services from market place, also these services can be used to connect to the On-premise servers through AWS VPC’s.

The advantage of using AWS private Link (VPC Endpoint service),
This service provides a way, so that request doesn’t need to go thru internet, everything will happen securely with in the AWS Environment.

With help of AWS private link, we can connect not only multiple VPC’s but also connect on-premise server, data center to your AWS environment.
Everything will be secure.
All the request from data center which is like on-premise data center, will directly go to AWS without traversing the internet.

## Steps for Manual Creation

As we don't have any Physical Data Center, Let's create two VPC's,
one for "consumer" and other for "provider".

Assume Consumer VPC as Physical Data center.

Make a request to Provider VPC and Consumer VPC will consume those services.

### Request Flow:
On Consumer VPC side, request will be originating.
That request can be originated from a private server that will endup onto the VPC endpoint.
From VPC endpoint request will be forwarded to AWS Private Link.
AWS Private Link will forward that request to NLB and then it will end up into our service Provider ec2 instance, where application is serving those requests.

### Set up Provider VPC
- Create VPC with CIDR range - 11.0.0.0/16
- Create IGW and attach it to VPC
- Create 2 Public and 2 Private Subnets in 2 different AZ
```
  Public Subnet 1 CIDR Range - 11.0.0.0/24
  Public Subnet 2 CIDR Range - 11.0.1.0/24
  Private Subnet 1 CIDR Range - 11.0.2.0/24
  Private Subnet 2 CIDR Range - 11.0.3.0/24
```
- Create Public and Private Route Table and attach Subnets to the Route Table.
- Create Route entry for IGW in Public Route Table.
- Create Security Group.
- Create EC2 instance inside Public and Private Subnet.
- Create Nat Gateway inside the public subnet, and make route entry inside the Private route table for NGW, so that instance within the private subnet can have access to internet.
- Download apache2 inside the Private instance.
- Create a Target Group and select protocol as TCP.
- Create Network Load Balancer and select Private Subnets and SG with port 80 enabled. Select Target Group and choose TCP protocol.
- To Integrate AWS Private Link, go inside the NLB and go to integration section and navigate to VPC endpoint services, click on Create Endpoint services and select NLB as LB type, select IPV4 and create.

### Set up Consumer VPC

- Create VPC with CIDR range - 21.0.0.0/16
- Create IGW and attach it to VPC
- Create 2 Public and 2 Private Subnets in 2 different AZ
```
  Public Subnet 1 CIDR Range - 21.0.0.0/24
  Public Subnet 2 CIDR Range - 21.0.1.0/24
  Private Subnet 1 CIDR Range - 21.0.2.0/24
  Private Subnet 2 CIDR Range - 21.0.3.0/24
```
- Create Public and Private Route Table and attach Subnets to the Route Table.
- Create Route entry for IGW in Public Route Table.
- Create Security Group.
- Create EC2 instance in both public and Private Subnet.
- Create VPC Endpoint.
- VPC > endpoints > create endpoints > provide name > select other endpoint services > provide service name (provide the endpoint service name of Provider VPC, as it needs to communicate with that service)  > select consumer VPC > select private subnets (request from this private subnet instance will go to endpoint and from endpoint to AWS private Link and from AWS private Link to NLB and from NLB to TG and from TG to ec2 instance of private subnet in Provider VPC) >  select SG  with port 80 enable > create endpoint
- Once endpoint is created and connected to Endpoint service, but endpoint needs approval from endpoint service.
- Go to VPC > end point services > Endpoint connections > select the requester and click on Actions > click on Accept endpoint connection request.
- Copy the DNS name of VPC endpoint and go to Private instance of Consumer, do the curl,
```
curl <dns of VPC endpoint>  
```



