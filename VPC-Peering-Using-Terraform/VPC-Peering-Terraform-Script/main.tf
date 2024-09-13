provider "aws" {
	region = var.region
	access_key = var.access_key
	secret_key = var.secret_key
}

resource "aws_key_pair" "key" {
	key_name = var.key_name
	public_key = var.public_key
}

resource "aws_vpc" "main_1" {
	cidr_block = "10.0.0.0/16"
	enable_dns_hostnames = "true"
	tags = { Name = "vpc_1" }
}

resource "aws_vpc" "main_2" {
	cidr_block = "11.0.0.0/16"
	enable_dns_hostnames = "true"
	tags = { Name = "vpc_2" }
}

resource "aws_internet_gateway" "main_igw_1" {
	tags = { Name = "igw-vpc1" }
}

resource "aws_internet_gateway" "main_igw_2" {
	tags = { Name = "igw-vpc2" }
}

resource "aws_internet_gateway_attachment" "attach_igw_vpc1" {
	internet_gateway_id = aws_internet_gateway.main_igw_1.id
	vpc_id = aws_vpc.main_1.id
}

resource "aws_internet_gateway_attachment" "attach_igw_vpc2" {
	internet_gateway_id = aws_internet_gateway.main_igw_2.id
	vpc_id = aws_vpc.main_2.id
}

resource "aws_subnet" "Public_1" {
	vpc_id = aws_vpc.main_1.id
	cidr_block = "10.0.0.0/24"
	availability_zone = var.availability_zone_1
	tags = { Name = "subnet-vpc1" }
}

resource "aws_subnet" "Public_2" {
	vpc_id = aws_vpc.main_2.id
	cidr_block = "11.0.0.0/24"
	availability_zone = var.availability_zone_2
	tags = { Name = "Subnet-vpc2" }
}

resource "aws_route_table" "PublicRouteTable_1" {
	vpc_id = aws_vpc.main_1.id
	tags = { Name = "RouteTable-vpc1" }
}

resource "aws_route_table" "PublicRouteTable_2" {
	vpc_id = aws_vpc.main_2.id
	tags = { Name = "RouteTable-vpc2" }
}

resource "aws_route_table_association" "Associate-1" {
	route_table_id = aws_route_table.PublicRouteTable_1.id
	subnet_id = aws_subnet.Public_1.id
}

resource "aws_route_table_association" "Associate-2" {
	route_table_id = aws_route_table.PublicRouteTable_2.id
	subnet_id = aws_subnet.Public_2.id
}

resource "aws_route" "route_1" {
	gateway_id = aws_internet_gateway.main_igw_1.id
	route_table_id = aws_route_table.PublicRouteTable_1.id
	destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "route_2" {
	gateway_id = aws_internet_gateway.main_igw_2.id
	route_table_id = aws_route_table.PublicRouteTable_2.id
	destination_cidr_block = "0.0.0.0/0"
}

locals {
	ingress_rules  = [{
		description = "Ingress rule for ssh"
		port = 22
	},
	{
		description = "Ingress rule for HTTP"
		port = 80
	}]
}

resource "aws_security_group" "sg_tf_vpc1" {
	name = "sg_tf_1"
	description = "SG for vpc-1"
	vpc_id = aws_vpc.main_1.id
	tags = { Name = "vpc1_sg" }
	
	dynamic "ingress" {
		for_each = local.ingress_rules
		content {
			description = ingress.value.description
			to_port = ingress.value.port
			from_port = ingress.value.port
			protocol = "tcp"
			cidr_blocks = [ "0.0.0.0/0" ]
		}
	}
}

resource "aws_security_group" "sg_tf_vpc2" {
	name = "sg_tf_2"
	description = "SG for vpc-2"
	vpc_id = aws_vpc.main_2.id
	tags = { Name = "vpc2_sg" }

	dynamic "ingress" {
		for_each = local.ingress_rules
		content {
			description = ingress.value.description
			to_port = ingress.value.port
			from_port = ingress.value.port
			protocol = "tcp"
			cidr_blocks = [ "0.0.0.0/0" ]
		}
	}
}

resource "aws_vpc_security_group_egress_rule" "egress_vpc1" {
	security_group_id = aws_security_group.sg_tf_vpc1.id
	ip_protocol = "-1"
	cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "egress_vpc2" {
	security_group_id = aws_security_group.sg_tf_vpc2.id
	ip_protocol = "-1"
	cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_instance" "instance1" {
	ami = var.ami
	instance_type = var.instance_type
	subnet_id = aws_subnet.Public_1.id
	key_name = var.key_name
	associate_public_ip_address = "true"
	vpc_security_group_ids = [ aws_security_group.sg_tf_vpc1.id ]
	tags = { Name = "Instance_10" }

	connection {
		type = "ssh"
		user = "ec2-user"
		private_key = file("/home/yash/keys/aws_key")
		timeout = "4m"
		host = self.public_ip
	}

	provisioner "remote-exec" {
		inline = [
			"sudo yum update",
			"sudo yum install httpd -y",
			"sudo systemctl status httpd",
			"sudo systemctl enable httpd"
			]
	}
}

resource "aws_instance" "instance2" {
	ami = var.ami
	instance_type = var.instance_type
	key_name = var.key_name
	subnet_id = aws_subnet.Public_2.id
	associate_public_ip_address = "true"
	vpc_security_group_ids = [ aws_security_group.sg_tf_vpc2.id ]
	tags = { Name = "Instance_20" }

	connection {
		type = "ssh"
		host = self.public_ip
		user = "ec2-user"
		private_key = file("/home/yash/keys/aws_key")
		timeout = "4m" 
	}
	provisioner "remote-exec" {
		inline = [
			"sudo yum update -y",
			"sudo yum install httpd -y",
			"sudo systemctl status httpd",
			"sudo systemctl enable httpd"
			]
	}
}

resource "aws_vpc_peering_connection" "VPCPeerConnection" {
	vpc_id = aws_vpc.main_1.id
	peer_vpc_id = aws_vpc.main_2.id
	auto_accept = true
	
	tags = { Name = "peering_tf_2" }
	
	accepter {
		allow_remote_vpc_dns_resolution = true
	}

	requester {
		allow_remote_vpc_dns_resolution = true
	}
}

resource "aws_route" "route_vpc_1" {
	route_table_id = aws_route_table.PublicRouteTable_2.id
	vpc_peering_connection_id = aws_vpc_peering_connection.VPCPeerConnection.id
	destination_cidr_block = "10.0.0.0/16"
}

resource "aws_route" "route_vpc_2" {
	route_table_id = aws_route_table.PublicRouteTable_1.id
	vpc_peering_connection_id = aws_vpc_peering_connection.VPCPeerConnection.id
	destination_cidr_block = "11.0.0.0/16"
}

data "aws_instance" "publicip_1" {
	filter {
		name = "tag:Name"
		values = [ "Instance_10" ]
	}
	depends_on = [ aws_instance.instance1 ]
}

data "aws_instance" "publicip_2" {
	filter {
		name = "tag:Name"
		values = [ "Instance_20" ]
	}
	depends_on = [ aws_instance.instance2 ]
}

data "aws_vpc_peering_connection" "peering" {
	filter {
		name = "tag:Name"
		values = [ "peering_tf_2" ]
	}
	depends_on = [ aws_vpc_peering_connection.VPCPeerConnection ]
}

output "public_ip_1" {
	value = data.aws_instance.publicip_1.public_ip
}

output "public_ip_2" {
	value = data.aws_instance.publicip_2.public_ip
}

output "peering_id" {
	value = data.aws_vpc_peering_connection.peering.id
}
