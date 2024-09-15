
# VPC Transit Gateway

AWS Transit Gateway is a fully managed service that connect VPC's and On-Premises networks through a central hub without relying on numerours point-to-point connections or Transit VPC.

Using Transit Gateway, user can manage multiple connections very easily.

Transit Gateway can support more than 1000's of connections.

Transit Gateway peering only Possible across regions, not within region.


## Difference between VPC Peering and Transit Gateway?

There are 2 different approaches to connect to multiple VPC's.
- One option is to choose VPC Peering.
- Second option is to enable communication between networks, AWS Transit Gateway

Both (VPC Peering and Transit Gateway) does same thing, connecting to multiple VPC's.

Creating a Peering connection is easy and simple.
Owner of VPC A creates a peering request and the Ownerof VPC B accepts the peering request. After the virtual peering is in place, all we need to do is to update the routing tables.

However, need to setup a VPC Peering between every VPC.
Therefore, the number of VPC Peering grows exponentially with the number of VPC's that we need to connect.

Good thing about Transit Gateway is, need to create a single Transit Gateway and it can handle multiple VPC's, so that these VPC's can communicate with each other.


## Steps to create Transit Gateway and attaching VPC's to it Manually in AWS:

- In Real time, there will be Private subnets and resources will be running inside the Private subnet. Here taking only public subnet for practice.
- Create 3 vpc, with each one public subnet and one route table, associate subnet with route table, and create route by making entry of IGW.

```bash
     -  VPC1 -> 12.0.0.0/16 
        subnet -> 12.0.1.0/24
        create IGW attach to VPC
        create Route table and create Route entry for IGW 
        Create EC2 (Install apache2)
        Create Security Group with necessary Ports open.
```
```bash
     -  VPC2 -> 13.0.0.0/16 
        subnet -> 13.0.1.0/24
        create IGW attach to VPC
        create Route table and create Route entry for IGW 
        Create EC2 (Install apache2)
        Create Security Group with necessary Ports open.
```

```bash
     -  VPC3 -> 14.0.0.0/16 
        subnet -> 14.0.1.0/24
        create IGW attach to VPC
        create Route table and create Route entry for IGW 
        Create EC2 (install nginx)
        Create Security Group with necessary Ports open.
```

- Create Transit Gateway to let multiple vpc’s present inside the account to communicate with each other.
```bash
    Create Transit Gateway.
    provide name  
    provide description
    Amazon will assign ASN(autonomous system number) If we don’t   provide, this is the route identification, when transit gateway is created, vpc will be able to find the route based on the number and then they will be able to navigate and communicate within the VPC.
    If vpc are created in other accounts, then select cross account sharing option.
    create Transit-gateway. 
```

- Once Transit Gateway is created, follow below steps,
```bash
   Once transit gateway is created, go to VPC.
   Transit Gateway section.
   Transit gateway attachments. 
   Create transit gateway attachments. 
   Provide name (tg-attachment-vpc1) 
   select TG 
   select VPC1 
   create TG Attachment.

   Do same for VPC2 and VPC3, just need to change name of TG Attachment, 
   tg-attachment-vpc2 for VPC2
   tg-attachment-vpc3 for VPC3
```

- Once Transit Gateway is attached to VPC's, need to modify Route tables.

```bash
  Go to Route table of VPC1
  Edit Routes
  Add Route
  Provide VPC2 IP address range and in Target section select Transit Gateway  and provide Transit Gateway attachment of VPC1.
  In same RT of VPC1, create route with VPC3 IP Address and select Transit Gateway attachment of VPC1.

  With this VPC1 can communicate with VPC2 and VPC3
```

```bash
  For vpc2 route table, add routes of vpc1 and vpc3 IP address range by selecting tg-attachment-vpc2 in Target section.

  with this VPC2 can communicate with VPC1 and VPC3

  For vpc3 route-table, add routes of vpc1 and vpc2 with tg-attachment-vpc3.

  with this VPC3 can communicate with VPC1 and VPC2.
```

- Lastly connect to Instances of VPC1, VPC2, VPC3
```bash
  Login to ec2 of vpc1 > curl <privateIP of ec2 of vpc2> and then do for instance of vpc3.
  Do this same by logging in to instances of vpc2 and vpc3.
```
- In this way, we can access applications running inside the instances of multiple VPC's using Transit Gateway.

