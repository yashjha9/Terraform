provider "aws" {
        region = var.region
}

resource "aws_key_pair" "key" {
        key_name = var.key_name
        public_key = var.public_key
}

resource "aws_vpc" "main" {
        cidr_block = "10.0.0.0/16"
        tags = { Name = "vpc_tf" }
}

resource "aws_internet_gateway" "main_igw" {
        tags = { Name = "igw_tf" }
}

resource "aws_internet_gateway_attachment" "attach_igw_vpc" {
        internet_gateway_id = aws_internet_gateway.main_igw.id
        vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "Public_1" {
        vpc_id = aws_vpc.main.id
        cidr_block = "10.0.0.0/24"
        availability_zone = "ap-south-1a"
        tags = { Name = "Public_Subnet_1" }
}

resource "aws_subnet" "Public_2" {
        vpc_id = aws_vpc.main.id
        cidr_block = "10.0.1.0/24"
        availability_zone = "ap-south-1b"
        tags = { Name = "Public_Subnet_2" }
}

resource "aws_subnet" "Private_1" {
        vpc_id = aws_vpc.main.id
        cidr_block = "10.0.2.0/24"
        availability_zone = "ap-south-1a"
        tags = { Name = "Private_Subnet_1" }
}

resource "aws_subnet" "Private_2" {
        vpc_id = aws_vpc.main.id
        cidr_block = "10.0.3.0/24"
        availability_zone = "ap-south-1b"
        tags = { Name = "Private_Subnet_2" }
}

resource "aws_route_table" "PublicRouteTable" {
        vpc_id = aws_vpc.main.id
        tags = { Name = "Public_RT" }
}

resource "aws_route_table" "PrivateRouteTable" {
        vpc_id = aws_vpc.main.id
        tags = { Name = "Private_RT" }
}

resource "aws_route_table_association" "Associate-1" {
        route_table_id = aws_route_table.PublicRouteTable.id
        subnet_id = aws_subnet.Public_1.id
}

resource "aws_route_table_association" "Associate-2" {
        route_table_id = aws_route_table.PublicRouteTable.id
        subnet_id = aws_subnet.Public_2.id
}

resource "aws_route_table_association" "Associate-3" {
        route_table_id = aws_route_table.PrivateRouteTable.id
        subnet_id = aws_subnet.Private_1.id
}

resource "aws_route_table_association" "Associate-4" {
        route_table_id = aws_route_table.PrivateRouteTable.id
        subnet_id = aws_subnet.Private_2.id
}

resource "aws_route" "route_igw"{
        gateway_id = aws_internet_gateway.main_igw.id
        route_table_id = aws_route_table.PublicRouteTable.id
        destination_cidr_block = "0.0.0.0/0"
}

resource "aws_eip" "eip" {
        domain = "vpc"
}

resource "aws_nat_gateway" "main_ngw" {
        allocation_id = aws_eip.eip.id
        subnet_id = aws_subnet.Public_2.id
        tags = { Name = "ngw_tf" }
}


resource "aws_route" "route_ngw" {
        route_table_id = aws_route_table.PrivateRouteTable.id
        nat_gateway_id = aws_nat_gateway.main_ngw.id
        destination_cidr_block = "0.0.0.0/0"
}

locals {
        ingress_rules = [{
                description = "Ingress Rule for SSH"
                port = 22
        },
        {
                description = "Ingress Rule for HTTP"
                port = 80
        }]
}

resource "aws_security_group" "main_sg" {
        description = "creating using terraform"
        name = "sg_tf"
        vpc_id = aws_vpc.main.id
        tags = { Name = "sg_tf" }
        dynamic "ingress" {
                for_each = local.ingress_rules
                content {
                        description = ingress.value.description
                        from_port = ingress.value.port
                        to_port = ingress.value.port
                        protocol = "tcp"
                        cidr_blocks = [ "0.0.0.0/0" ]
                }
        }
}

resource "aws_vpc_security_group_egress_rule" "egress" {
        security_group_id = aws_security_group.main_sg.id
        ip_protocol = "-1"
        cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_instance" "Private" {
        ami = var.ami
        instance_type = var.instance_type
        key_name = var.key_name
        vpc_security_group_ids = [ aws_security_group.main_sg.id ]
        subnet_id = aws_subnet.Private_2.id
        tags = { Name = "Private_Instance" }
}

resource "aws_instance" "Bastion" {
        ami = var.ami
        instance_type = var.instance_type
        key_name = var.key_name
        vpc_security_group_ids = [ aws_security_group.main_sg.id ]
        subnet_id = aws_subnet.Public_1.id
        associate_public_ip_address = "true"
        tags = { Name = "Bastion_Instance" }

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

resource "aws_lb_target_group" "tg" {
        name = "tg-1"
        port = 80
        protocol = "HTTP"
        vpc_id = aws_vpc.main.id

        target_health_state {
                 enable_unhealthy_connection_termination = false
        }
}

resource "aws_lb_target_group_attachment" "tg_attach" {
        target_group_arn = aws_lb_target_group.tg.arn
        target_id = aws_instance.Private.id
        port = 80
}

resource "aws_lb" "lb" {
        name = "lb-tf"
        internal = false
        load_balancer_type = "application"
        security_groups = [ aws_security_group.main_sg.id ]
        subnets = [ aws_subnet.Public_1.id, aws_subnet.Public_2.id ]
}

resource "aws_lb_listener" "listener" {
        load_balancer_arn = aws_lb.lb.arn
        port = "80"
        protocol = "HTTP"

        default_action {
                type = "forward"
                target_group_arn = aws_lb_target_group.tg.arn
        }
}

resource "aws_lb_listener_rule" "lb_rule" {
        listener_arn = aws_lb_listener.listener.arn
        priority = 100

        action {
                type = "forward"
                target_group_arn = aws_lb_target_group.tg.arn
        }

        condition {
                path_pattern {
                        values = ["/static/*"]
                }
        }
}


output "fetching_dns_of_lb" {
        value = aws_lb.lb.dns_name
}

data "aws_instance" "publicIP" {
        filter {
                name = "tag:Name"
                values = [ "Bastion_Instance" ]
        }
        depends_on = [
                aws_instance.Bastion
        ]
}

output "Fetching_public_ip_of_instance" {
        value = data.aws_instance.publicIP.public_ip
}

output "fetching_private_ip_address" {
    value = aws_instance.Private.private_ip
}
