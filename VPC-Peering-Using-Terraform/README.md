
# VPC Peering

VPC Peering enables us to route the traffic between two VPC's using Private IP addresses.
We can create VPC Peering between our own VPC's or with a VPC in another AWS account,
The VPCs can be in different Regions (also known as an inter-Region VPC peering connection).

A VPC peering connection helps you to facilitate the transfer of data. 

We can also use a VPC peering connection to allow other VPCs to access resources you have in one of your VPCs.

When establishing peering relationships between VPCs across different AWS Regions, resources in the VPCs (for example, EC2 instances and Lambda functions) in different AWS Regions can communicate with each other using private IP addresses, without using a gateway, VPN connection, or network appliance.

The traffic remains in the private IP address space. All inter-Region traffic is encrypted with no single point of failure, or bandwidth bottleneck. Traffic always stays on the global AWS backbone, and never traverses the public internet.

## Manual way to Create VPC Peering:
- Create two VPC's.
```bash
    VPC1 CIDR Range = 10.0.0.0/16
    VPC2 CIDR Range = 11.0.0.0/16
```
- Create two public subnets in different Availability zones inside two VPC's.
```bash
    Public Subnet in VPC1 CIDR Range = 10.0.0.0/24
    Public Subnet in VPC2 CIDR Range = 11.0.0.0/24
```
- Create Public Route Table in two VPC's and associate Subnets to the Route Table.
- Create Internet Gateway for each VPC and attach it to each VPC.
- Create a Route entry for IGW inside the Public Route Table of each VPC with destinattion CIDR Range - 0.0.0.0/0
- Create Security Groups for each VPC with HTTP, SSH port open.
- Create single instance in Public subnet for each VPC and install apache2 inside those instances.
- To establish Peering, go to VPC > Peering Connections > Create Peering connection > Provide name > Select VPC1 as local VPC > Select VPC2 as acceptor > click on Create Peering connection
- Whenever Peering is created, acceptor should accept Peering connection of the requester.
- To accept the request, go to Actions of acceptor VPC >  accept request.
- Once Peering is established, Modify Route tables.
```bash
    Make a route entry inside Route Table of VPC1,
    Provide VPC2 IP address (11.0.0.0/16) in the Destination section.
    Select Peering Connection in Target section.
```
```bash
    Make a route entry inside Route Table of VPC2,
    Provide VPC1 IP address (10.0.0.0/16) in the Destination section.
    Select Peering Connection in Target section.
```
- Login to the Instance of VPC1 and do curl to access/see application running inside the instance of VPC2. 
```bash
    curl <private IP of Instance of VPC2>
```
- Need to do same by logging inside the Instance of VPC2 and doing curl 
```bash
    curl <private IP of Instance of VPC1>
```
