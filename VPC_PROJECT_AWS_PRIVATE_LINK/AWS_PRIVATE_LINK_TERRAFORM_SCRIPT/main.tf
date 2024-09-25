provider "aws" {
        region = var.region
        access_key = var.access_key
        secret_key = var.secret_key
}

resource "aws_key_pair" "key" {
        key_name = var.key_name
        public_key = var.public_key
}

resource "aws_vpc" "consumer_vpc" {
        cidr_block = "20.0.0.0/16"
        tags = { Name = "consumer" }
}

resource "aws_vpc" "provider_vpc" {
        cidr_block = "21.0.0.0/16"
        tags = { Name = "provider" }
}

resource "aws_internet_gateway" "provider_igw" {
        tags = { Name = "provider_igw" }
}

resource "aws_internet_gateway_attachment" "attach_1" {
        vpc_id = aws_vpc.provider_vpc.id
        internet_gateway_id = aws_internet_gateway.provider_igw.id
}

resource "aws_internet_gateway" "consumer_igw" {
        tags = { Name = "consumer_igw" }
}

resource "aws_internet_gateway_attachment" "attach_2" {
        vpc_id = aws_vpc.consumer_vpc.id
        internet_gateway_id = aws_internet_gateway.consumer_igw.id
}

resource "aws_subnet" "Public_1" {
        vpc_id = aws_vpc.provider_vpc.id
        cidr_block = "21.0.1.0/24"
        availability_zone = "ap-south-1a"
        tags = { Name = "Public_Subnet_1_Provider" }
}

resource "aws_subnet" "Public_2" {
        vpc_id = aws_vpc.provider_vpc.id
        cidr_block = "21.0.2.0/24"
        availability_zone = "ap-south-1b"
        tags = { Name = "Public_Subnet_2_Provider" }
}

resource "aws_subnet" "Private_1" {
        vpc_id = aws_vpc.provider_vpc.id
        cidr_block = "21.0.3.0/24"
        availability_zone = "ap-south-1a"
        tags = { Name = "Private_Subnet_1_Provider" }
}

resource "aws_subnet" "Private_2" {
        vpc_id = aws_vpc.provider_vpc.id
        cidr_block = "21.0.4.0/24"
        availability_zone = "ap-south-1b"
        tags = { Name = "Private_Subnet_2_Provider" }
}

resource "aws_subnet" "Public_3" {
        vpc_id = aws_vpc.consumer_vpc.id
        cidr_block = "20.0.1.0/24"
        availability_zone = "ap-south-1a"
        tags = { Name = "Public_Subnet_1_Consumer" }
}

resource "aws_subnet" "Public_4" {
        vpc_id = aws_vpc.consumer_vpc.id
        cidr_block = "20.0.2.0/24"
        availability_zone = "ap-south-1b"
        tags = { Name = "Public_Subnet_2_Consumer" }
}

resource "aws_subnet" "Private_3" {
        vpc_id = aws_vpc.consumer_vpc.id
        cidr_block = "20.0.3.0/24"
        availability_zone = "ap-south-1a"
        tags = { Name = "Private_Subnet_1_Consumer" }
}

resource "aws_subnet" "Private_4" {
        vpc_id = aws_vpc.consumer_vpc.id
        cidr_block = "20.0.4.0/24"
        availability_zone = "ap-south-1b"
        tags = { Name = "Private_Subnet_2_Consumer" }
}

resource "aws_route_table" "provider_public_route_table" {
        vpc_id = aws_vpc.provider_vpc.id
        tags = { Name = "provider_public_route_table" }
}

resource "aws_route_table" "provider_private_route_table" {
        vpc_id = aws_vpc.provider_vpc.id
        tags = { Name = "provider_private_route_table" }
}

resource "aws_route_table" "consumer_public_route_table" {
        vpc_id = aws_vpc.consumer_vpc.id
        tags = { Name = "consumer_public_route_table" }
}

resource "aws_route_table" "consumer_private_route_table" {
        vpc_id = aws_vpc.consumer_vpc.id
        tags = { Name = "consumer_private_route_table" }
}

resource "aws_route_table_association" "provider_route_association_1" {
        subnet_id = aws_subnet.Public_1.id
        route_table_id = aws_route_table.provider_public_route_table.id
}

resource "aws_route_table_association" "provider_route_table_association_2" {
        subnet_id = aws_subnet.Public_2.id
        route_table_id = aws_route_table.provider_public_route_table.id
}

resource "aws_route_table_association" "provider_route_table_association_3" {
        subnet_id = aws_subnet.Private_1.id
        route_table_id = aws_route_table.provider_private_route_table.id
}

resource "aws_route_table_association" "provider_route_table_association_4" {
        subnet_id = aws_subnet.Private_2.id
        route_table_id = aws_route_table.provider_private_route_table.id
}

resource "aws_route_table_association" "consumer_route_table_association_5" {
        subnet_id = aws_subnet.Public_3.id
        route_table_id = aws_route_table.consumer_public_route_table.id
}

resource "aws_route_table_association" "consumer_route_table_association_6" {
        subnet_id = aws_subnet.Public_4.id
        route_table_id = aws_route_table.consumer_public_route_table.id
}

resource "aws_route_table_association" "consumer_route_table_association_7" {
        subnet_id = aws_subnet.Private_3.id
        route_table_id = aws_route_table.consumer_private_route_table.id
}

resource "aws_route_table_association" "consumer_route_table_association_8" {
        subnet_id = aws_subnet.Private_4.id
        route_table_id = aws_route_table.consumer_private_route_table.id
}

resource "aws_route" "provider_route" {
        route_table_id = aws_route_table.provider_public_route_table.id
        gateway_id = aws_internet_gateway.provider_igw.id
        destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "consumer_route" {
        route_table_id  = aws_route_table.consumer_public_route_table.id
        gateway_id = aws_internet_gateway.consumer_igw.id
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
        }]
}

resource "aws_security_group" "provider_sg" {
        vpc_id = aws_vpc.provider_vpc.id
        description = "SG of Provider"
        name = "provider_sg"
        tags = { Name = "provider_sg" }

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

resource "aws_vpc_security_group_egress_rule" "provider_egress" {
        security_group_id = aws_security_group.provider_sg.id
        ip_protocol = "-1"
        cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_security_group" "consumer_sg" {
        vpc_id = aws_vpc.consumer_vpc.id
        description = "SG of Consumer"
        name = "consumer_sg"
        tags = { Name = "consumer_sg" }

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

resource "aws_vpc_security_group_egress_rule" "consumer_egress" {
        security_group_id = aws_security_group.consumer_sg.id
        ip_protocol = "-1"
        cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_instance" "provider_public_instance" {
        ami = "ami-0ad21ae1d0696ad58"
        instance_type = "t2.micro"
        subnet_id = aws_subnet.Public_1.id
        key_name = var.key_name
        vpc_security_group_ids = [ aws_security_group.provider_sg.id ]
        associate_public_ip_address = "true"
        tags = { Name = "provider_public_instance" }

        connection {
                type = "ssh"
                user = "ubuntu"
                host = self.public_ip
                private_key = file("/home/yash/keys/aws_key")
        }

        provisioner "file" {
                source = "/home/yash/keys/aws_key"
                destination = "/home/ubuntu/aws_key"
        }

        provisioner "remote-exec" {
                inline = [
                        "chmod 400 /home/ubuntu/aws_key"
                        ]
        }
}

resource "aws_instance" "consumer_public_instance" {
        ami = "ami-0ad21ae1d0696ad58"
        instance_type = "t2.micro"
        subnet_id = aws_subnet.Public_3.id
        key_name = var.key_name
        vpc_security_group_ids = [ aws_security_group.consumer_sg.id ]
        associate_public_ip_address = "true"
        tags = { Name = "consumer_public_instance" }

        connection {
                type = "ssh"
                user = "ubuntu"
                host = self.public_ip
                private_key = file("/home/yash/keys/aws_key")
        }

        provisioner "file" {
                source = "/home/yash/keys/aws_key"
                destination = "/home/ubuntu/aws_key"
        }

        provisioner "remote-exec" {
                inline = [
                        "chmod 400 /home/ubuntu/aws_key"
                        ]
        }
}

resource "aws_instance" "provider_private_instance" {
        ami = "ami-0ad21ae1d0696ad58"
        instance_type = "t2.micro"
        subnet_id = aws_subnet.Private_2.id
        key_name = var.key_name
        vpc_security_group_ids = [ aws_security_group.provider_sg.id ]
        tags = { Name = "provider_private_instance" }
}

resource "aws_instance" "consumer_private_instance" {
        ami = "ami-0ad21ae1d0696ad58"
        instance_type = "t2.micro"
        subnet_id = aws_subnet.Private_4.id
        key_name = var.key_name
        vpc_security_group_ids = [ aws_security_group.consumer_sg.id ]
        tags = { Name = "consumer_private_instance" }
}

resource "aws_eip" "eip" {
        domain = "vpc"
}

resource "aws_nat_gateway" "ngw_provider" {
        allocation_id = aws_eip.eip.id
        subnet_id = aws_subnet.Public_2.id
        tags = { Name = "ngw_provider" }
}

resource "aws_route" "route_ngw" {
        route_table_id = aws_route_table.provider_private_route_table.id
        nat_gateway_id = aws_nat_gateway.ngw_provider.id
        destination_cidr_block = "0.0.0.0/0"
}

resource "aws_lb_target_group_attachment" "tg_attach" {
        target_group_arn = aws_lb_target_group.tg.arn
        target_id = aws_instance.provider_private_instance.id
        port = 80
}

resource "aws_lb_target_group" "tg" {
        name = "provider-tg"
        port = 80
        protocol = "TCP"
        vpc_id = aws_vpc.provider_vpc.id
}

resource "aws_lb" "provider_lb" {
        name = "provider-lb"
        internal = "true"
        load_balancer_type = "network"
        subnets = [ aws_subnet.Private_1.id, aws_subnet.Private_2.id ]
        security_groups = [ aws_security_group.provider_sg.id ]

        tags = { Environment = "production" }
}



resource "aws_lb_listener" "listener_provider_lb" {
        load_balancer_arn = aws_lb.provider_lb.arn
        port = "80"
        protocol = "TCP"

        default_action {
                type = "forward"
                target_group_arn = aws_lb_target_group.tg.arn
        }
}

resource "aws_vpc_endpoint_service" "vpc_endpoint_service" {
        tags = { Name = "Provider_endpoint_service" }
        network_load_balancer_arns = [ aws_lb.provider_lb.arn ]
        acceptance_required = false # if given true then need to go and manually approve request 

}

resource "aws_vpc_endpoint" "vpc_endpoint_consumer" {
        vpc_id = aws_vpc.consumer_vpc.id
        tags = { Name = "vpc_endpoint_consumer" }
        service_name = aws_vpc_endpoint_service.vpc_endpoint_service.service_name
        subnet_ids = [ aws_subnet.Private_3.id, aws_subnet.Private_4.id ]
        vpc_endpoint_type = "Interface"
        security_group_ids = [ aws_security_group.consumer_sg.id ]
}
