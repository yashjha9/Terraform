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
        tags = { Name = "vpc_1" }
}

resource "aws_vpc" "main_2" {
        cidr_block = "11.0.0.0/16"
        tags = { Name = "vpc_2" }
}

resource "aws_vpc" "main_3" {
        cidr_block = "12.0.0.0/16"
        tags = { Name = "vpc_3" }
}

resource "aws_internet_gateway" "main_igw_1" {
        vpc_id = aws_vpc.main_1.id
        tags = { Name = "igw_1" }
}

resource "aws_internet_gateway" "main_igw_2" {
        vpc_id = aws_vpc.main_2.id
        tags = { Name = "igw_2" }
}

resource "aws_internet_gateway" "main_igw_3" {
        vpc_id = aws_vpc.main_3.id
        tags = { Name = "igw_3" }
}

resource "aws_subnet" "Public_1" {
        vpc_id = aws_vpc.main_1.id
        cidr_block = "10.0.0.0/24"
        availability_zone = "ap-south-1a"
        tags = { Name = "Public_Subnet_VPC1" }
}

resource "aws_subnet" "Public_2" {
        vpc_id = aws_vpc.main_2.id
        cidr_block = "11.0.0.0/24"
        availability_zone = "ap-south-1b"
        tags = { Name = "Public_Subnet_VPC2" }
}

resource "aws_subnet" "Public_3" {
        vpc_id = aws_vpc.main_3.id
        cidr_block = "12.0.0.0/24"
        availability_zone = "ap-south-1a"
        tags = { Name = "Public_Subnet_VPC3" }
}

resource "aws_route_table" "PublicRouteTable_1" {
        vpc_id = aws_vpc.main_1.id
        tags = { Name = "Public_RT_VPC1" }
}

resource "aws_route_table" "PublicRouteTable_2" {
        vpc_id = aws_vpc.main_2.id
        tags = { Name = "Public_RT_VPC2" }
}

resource "aws_route_table" "PublicRouteTable_3" {
        vpc_id = aws_vpc.main_3.id
        tags = { Name = "Public_RT_VPC3" }
}

resource "aws_route_table_association" "Associate_1" {
        route_table_id = aws_route_table.PublicRouteTable_1.id
        subnet_id = aws_subnet.Public_1.id
}

resource "aws_route_table_association" "Associate_2" {
        route_table_id = aws_route_table.PublicRouteTable_2.id
        subnet_id = aws_subnet.Public_2.id
}

resource "aws_route_table_association" "Associate_3" {
        route_table_id = aws_route_table.PublicRouteTable_3.id
        subnet_id = aws_subnet.Public_3.id
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

resource "aws_route" "route_3" {
        gateway_id = aws_internet_gateway.main_igw_3.id
        route_table_id = aws_route_table.PublicRouteTable_3.id
        destination_cidr_block = "0.0.0.0/0"
}

locals {
        ingress_rules = [{
                description = "Ingress rule for SSH"
                port = 22
        },
        {
                description = "Ingress rule for HTTP"
                port = 80
        }
        ]
}

resource "aws_security_group" "sg_vpc1" {
        vpc_id = aws_vpc.main_1.id
        description = "SG of VPC1"
        name = "sg_vpc1"
        tags = { Name = "sg_vpc1" }

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
        security_group_id = aws_security_group.sg_vpc1.id
        ip_protocol = "-1"
        cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_instance" "instance_1" {
        ami = var.ami
        instance_type = var.instance_type
        subnet_id = aws_subnet.Public_1.id
        key_name = var.key_name
        associate_public_ip_address = "true"
        vpc_security_group_ids = [ aws_security_group.sg_vpc1.id ]
        tags = { Name = "Instance_vpc1" }

        connection {
                type = "ssh"
                user = "ubuntu"
                host = self.public_ip
                private_key = file("/home/yash/keys/aws_key")
                timeout = "4m"
        }

        provisioner "remote-exec" {
                inline = [
                        "sudo apt update",
                        "sudo apt upgrade -y",
                        "sudo apt install apache2 -y",
                        "sudo systemctl status apache2",
                        "sudo systemctl start apache2",
                        "sudo systemctl enable apache2"
                        ]
        }
}

resource "aws_security_group" "sg_vpc2" {
        vpc_id = aws_vpc.main_2.id
        description = "SG of VPC2"
        name = "sg_vpc2"
        tags = { Name = "sg_vpc2" }

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

resource "aws_vpc_security_group_egress_rule" "egress_vpc2" {
        security_group_id = aws_security_group.sg_vpc2.id
        ip_protocol = "-1"
        cidr_ipv4 = "0.0.0.0/0"
}


resource "aws_instance" "instance_2" {
        ami = var.ami
        instance_type = var.instance_type
        key_name = var.key_name
        subnet_id = aws_subnet.Public_2.id
        associate_public_ip_address = "true"
        vpc_security_group_ids = [ aws_security_group.sg_vpc2.id ]
        tags = { Name = "Instance_vpc2" }

        connection {
                type = "ssh"
                user = "ubuntu"
                host = self.public_ip
                private_key = file("/home/yash/keys/aws_key")
                timeout = "4m"
        }

        provisioner "remote-exec" {
                inline = [
                        "sudo apt update",
                        "sudo apt upgrade -y",
                        "sudo apt install apache2 -y",
                        "sudo systemctl status apache2",
                        "sudo systemctl start apache2",
                        "sudo systemctl enable apache2"
                        ]
        }
}

resource "aws_security_group" "sg_vpc3" {
        vpc_id = aws_vpc.main_3.id
        description = "SG for VPC3"
        name = "sg_vpc3"
        tags = { Name = "sg_vpc3" }

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

resource "aws_vpc_security_group_egress_rule" "egress_vpc3" {
        security_group_id = aws_security_group.sg_vpc3.id
        ip_protocol = "-1"
        cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_instance" "instance_3" {
        ami = var.ami
        instance_type = var.instance_type
        associate_public_ip_address = "true"
        key_name = var.key_name
        subnet_id = aws_subnet.Public_3.id
        vpc_security_group_ids = [ aws_security_group.sg_vpc3.id ]
        tags = { Name = "Instance_vpc3" }

        connection {
                type = "ssh"
                host = self.public_ip
                user = "ubuntu"
                private_key = file("/home/yash/keys/aws_key")
                timeout = "4m"
        }

        provisioner "remote-exec" {
                inline = [
                        "sudo apt update",
                        "sudo apt upgrade -y",
                        "sudo apt install apache2 -y",
                        "sudo systemctl status apache2",
                        "sudo systemctl start apache2",
                        "sudo systemctl enable apache2"
                        ]
        }
}

resource "aws_ec2_transit_gateway" "tgw_tf" {
        description = "tgw_tf"
        tags = { Name = "tgw_tf" }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_attachment_tgw_1" {
        transit_gateway_id = aws_ec2_transit_gateway.tgw_tf.id
        subnet_ids = [ aws_subnet.Public_1.id ]
        vpc_id = aws_vpc.main_1.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_attachment_tgw_2" {
        transit_gateway_id = aws_ec2_transit_gateway.tgw_tf.id
        subnet_ids = [ aws_subnet.Public_2.id ]
        vpc_id = aws_vpc.main_2.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_attachment_tgw_3" {
        transit_gateway_id = aws_ec2_transit_gateway.tgw_tf.id
        subnet_ids = [ aws_subnet.Public_3.id ]
        vpc_id = aws_vpc.main_3.id
}

resource "aws_route" "attach_tgw_to_route_1" {
        route_table_id = aws_route_table.PublicRouteTable_1.id
        transit_gateway_id = aws_ec2_transit_gateway.tgw_tf.id
        destination_cidr_block = "11.0.0.0/16"
}

resource "aws_route" "attach_tgw_to_route_2" {
        route_table_id = aws_route_table.PublicRouteTable_1.id
        transit_gateway_id = aws_ec2_transit_gateway.tgw_tf.id
        destination_cidr_block = "12.0.0.0/16"
}

resource "aws_route" "attach_tgw_to_route_3" {
        route_table_id = aws_route_table.PublicRouteTable_2.id
        transit_gateway_id = aws_ec2_transit_gateway.tgw_tf.id
        destination_cidr_block = "10.0.0.0/16"
}

resource "aws_route" "attach_tgw_to_route_4" {
        route_table_id = aws_route_table.PublicRouteTable_2.id
        transit_gateway_id = aws_ec2_transit_gateway.tgw_tf.id
        destination_cidr_block = "12.0.0.0/16"
}

resource "aws_route" "attach_tgw_to_route_5" {
        route_table_id = aws_route_table.PublicRouteTable_3.id
        transit_gateway_id = aws_ec2_transit_gateway.tgw_tf.id
        destination_cidr_block = "10.0.0.0/16"
}

resource "aws_route" "attach_tgw_to_route_6" {
        route_table_id = aws_route_table.PublicRouteTable_3.id
        transit_gateway_id = aws_ec2_transit_gateway.tgw_tf.id
        destination_cidr_block = "11.0.0.0/16"
}
