provider "aws" {
    region = var.region[0]
    access_key = var.access_key
    secret_key = var.secret_key
}

resource "aws_vpc" "main" {
    cidr_block = "13.0.0.0/16"
    tags = { Name = "vpc_tf" }
}

resource "aws_internet_gateway" "main_igw" {
    tags = { Name = "igw_tf" }
}

resource "aws_internet_gateway_attachment" "attach_igw" {
    vpc_id = aws_vpc.main.id
    internet_gateway_id = aws_internet_gateway.main_igw.id
}

resource "aws_subnet" "public_1" {
    cidr_block = "13.0.0.0/24"
    availability_zone = var.availability_zone_1
    vpc_id = aws_vpc.main.id
    tags = { Name = "Public_1" }
}

resource "aws_subnet" "public_2" {
    cidr_block = "13.0.1.0/24"
    availability_zone = var.availability_zone_2
    vpc_id = aws_vpc.main.id
    tags = { Name = "Public_2" }
}

resource "aws_subnet" "private_1" {
    cidr_block = "13.0.2.0/24"
    availability_zone = var.availability_zone_1
    vpc_id = aws_vpc.main.id
    tags = { Name = "Private_1" }
}

resource "aws_subnet" "private_2" {
    cidr_block = "13.0.3.0/24"
    availability_zone = var.availability_zone_2
    vpc_id = aws_vpc.main.id
    tags = { Name = "Private_2" }
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main.id
    tags = { Name = "PublicRT" }
}

resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.main.id
    tags = { Name = "PrivateRT" }
}

resource "aws_route_table_association" "associate_public_1" {
    subnet_id = aws_subnet.public_1.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "associate_public_2" {
    subnet_id = aws_subnet.public_2.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "associate_private_1" {
    subnet_id = aws_subnet.private_1.id
    route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "associate_private_2" {
    subnet_id = aws_subnet.private_2.id
    route_table_id = aws_route_table.private_rt.id
}

resource "aws_route" "route_igw" {
    gateway_id = aws_internet_gateway.main_igw.id
    route_table_id = aws_route_table.public_rt.id
    destination_cidr_block = "0.0.0.0/0"
}

resource "aws_eip" "eip" {
    domain = "vpc"
}

resource "aws_nat_gateway" "main_ngw" {
    allocation_id = aws_eip.eip.id
    subnet_id = aws_subnet.public_2.id
    tags = { Name = "ngw_tf" }
}

resource "aws_route" "route_ngw" {
    nat_gateway_id = aws_nat_gateway.main_ngw.id
    route_table_id = aws_route_table.private_rt.id
    destination_cidr_block = "0.0.0.0/0"
}

locals {
    ingress_rules = [{
        port = 22
        description = "Ingress rule for SSH"
    },
    {
        port = 80
        description = "Ingress rule for HTTP"
    }]
}

resource "aws_security_group" "main_sg" {
    vpc_id = aws_vpc.main.id
    description = "created using terraform"
    name = "sg"
    tags = { Name = sg_tf }

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

resource "aws_vpc_security_group_egress_rule" "egress" {
    security_group_id = aws_security_group.main_sg.id
    ip_protocol = "-1"
    cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_key_pair" "key" {
    key_name = var.key_name
    public_key = "${file("/home/yash/yash_workspace/keys/aws_key.pub")}"
} 

data "aws_ami" "fetch_ami" {
    most_recent = true
    owners = ["amazon"]

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
}

resource "aws_instance" "instance_1" {
    ami = data.aws_ami.fetch_ami.image_id
    instance_type = var.instance_type[var.region[0]]
    vpc_security_group_ids = [ aws_security_group.main_sg.id ]
    associate_public_ip_address = "true"
    subnet_id = aws_subnet.public_1.id
    key_name = aws_key_pair.key.key_name
    tags = { Name = "Bastion_Host" }

    connection {
        type = "ssh"
        host = self.public_ip
        user = "ubuntu"
        private_key = file("/home/yash/yash_workspace/keys/aws_key")
        timeout = "4m"
    }

    provisioner "file" {
        source = "/home/yash/yash_workspace/keys/aws_key"
        destination = "/home/ubuntu/key"
    }

    provisioner "remote-exec" {
        inline = "chmod 400 /home/ubuntu/key"
    }
}

resource "aws_launch_configuration" "launch_template" {
    name = "template_tf"
    image_id = data.aws_ami.fetch_ami.image_id
    instance_type = var.instance_type[var.region[0]]
    security_groups = [ aws_security_group.main_sg.id ]
    key_name = var.key_name
}

resource "aws_autoscaling_group" "main_asg" {
    name = "autoscaling_tf"
    max_size = 2
    min_size = 1
    desired_capacity = 2
    health_check_grace_period = 300
    health_check_type = "ELB"
    force_delete = "true"
    launch_configuration = aws_launch_configuration.launch_template.name
    vpc_zone_identifier = [ aws_subnet.private_1.id, aws_subnet.private_2.id ]
}

resource "aws_lb_target_group" "tg_tf" {
    name = "tg_tf"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.main.id

    target_health_state {
        enable_unhealthy_connection_termination = false
    }
}

resource "aws_lb" "lb_tf" {
    name = "lb_tf"
    internal = false
    load_balancer_type = "application"
    security_groups = [ aws_security_group.main_sg.id ]
    subnets = [ aws_subnet.public_1.id, aws_subnet.public_2.id ]
    tags = { Name = "lb_tf" }
} 

resource "aws_lb_listener" "listener_tf" {
    load_balancer_arn = aws_lb.lb_tf.arn
    port = "80"
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.tg_tf.arn
    }
}

resource "aws_lb_listener_rule" "rule_tf" {
    listener_arn = aws_lb_listener.listener_tf.arn
    priority = 100

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.tg_tf.arn
    }

    condition {
      path_pattern {
        values = ["/static/*"]
    }
  }
}

resource "aws_autoscaling_attachment" "attach_to_lb" {
    autoscaling_group_name = aws_autoscaling_group.main_asg.id
    lb_target_group_arn = aws_lb_target_group.tg_tf.arn
}

output "dns_of_lb" {
    value = aws_lb.lb_tf.dns_name
}
