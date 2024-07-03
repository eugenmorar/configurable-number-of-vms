provider "aws" {
    region = "us-east-1"
}

# Create a vpc 
resource "aws_vpc" "main" {
  cidr_block = "10.110.0.0/16"
  enable_dns_hostnames = true
  tags = {
      Name = "asssessment"
  }
}

# Create a public subnet in az-1a for assessment vms
resource "aws_subnet" "assessment-public-subnet" {
  
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.110.0.0/20"
  map_public_ip_on_launch = "true"
  availability_zone= "us-east-1a"

  tags = {
    Name = "assessment-public-subnet"
  } 
}

# Create an ig for public subnet
resource "aws_internet_gateway" "assessment-internet-gw" {
    vpc_id = "${aws_vpc.main.id}"
 
    tags = {
        Name = "assessment-internet-gw"
    }
}

# Create a route table for public subnet routing default to ig
resource "aws_route_table" "assessment-rt-table-public-ig" {
    vpc_id = "${aws_vpc.main.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.assessment-internet-gw.id}"
    }
 
    tags = {
        Name = "assessment-rt-external"
    }
}
 
# Create a route table associtation to public subnet
resource "aws_route_table_association" "assessment-rt-external-association" {
    subnet_id = "${aws_subnet.assessment-public-subnet.id}"
    route_table_id = "${aws_route_table.assessment-rt-table-public-ig.id}"
}

# Create an sg allowing external ssh and ping to each other
resource "aws_security_group" "assessment_security_group" {

    name        = "assessment-vm-sg"
    description = "Allow inbound traffic for assessment cases"
    vpc_id     = "${aws_vpc.main.id}"

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "10.110.0.0/16"]
    }

    ingress {
        from_port = "22"
        to_port = "22"
        protocol = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    tags = {
        Name = "assessment-vm-sg"
    }    
}

# Generate random passwords
resource "random_password" "password" {
  count            = var.vm_count
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_instance" "vm-instance" {
    count = var.vm_count

    ami = var.vm_flavor
    instance_type = var.vm_type
    key_name = "assessment-tf"
   
        vpc_security_group_ids = ["${aws_security_group.assessment_security_group.id}"]
    subnet_id     = "${aws_subnet.assessment-public-subnet.id}"

    associate_public_ip_address = true

    # provisioner "remote-exec" {

    #     inline = [
    #         "echo -e 'root:${random_password.password[count.index].result}' | sudo chpasswd"
    #     ]

    #     connection {
    #     type = "ssh"
    #     user = "ubuntu"
    #     private_key=file("./assessment-tf.pem")
    #     host = self.public_ip
    #     }

    # }
 
    tags = {
        Name = "vm-instance-${count.index}"
    }

    user_data = <<-EOF
        #!/bin/bash
        echo -e 'root:${random_password.password[count.index].result}' | sudo chpasswd
	EOF
}

resource "null_resource" "run_script" {

    triggers = {
        public_ip = aws_instance.vm-instance[var.vm_count - 1].public_ip
    }

    count = var.vm_count
    
    provisioner "remote-exec" {
        connection {
            type = "ssh"
            user = "ubuntu"
            private_key=file("./assessment-tf.pem")
            host = "${aws_instance.vm-instance[count.index % var.vm_count].public_ip}"
        }

        inline = ["echo 'connected!'"]
    }
  
    provisioner "local-exec" {
        command = "${path.module}/ping.sh ${aws_instance.vm-instance[count.index % var.vm_count].public_ip} ${aws_instance.vm-instance[count.index % var.vm_count].private_ip} ${aws_instance.vm-instance[(count.index + 1) % var.vm_count].private_ip} >> results"
    }
}

data "local_file" "results_file" {
  depends_on = [null_resource.run_script]
  filename   = "${path.module}/results"
}


