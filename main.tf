terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "ExampleVPC"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  tags = {
    Name = "ExampleSubnet"
  }
}


resource "aws_security_group" "my_security_group" {
  vpc_id = aws_vpc.my_vpc.id

  // describes how incoming traffic will be treated
  ingress {
    cidr_blocks = [
      "${var.ip_address}/32"
    ]
    //Allow anyone to connect through port 22
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  // describes how outgoing traffic will be treated, allow all
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "my_aws_instance1" {
  key_name = var.key_pair
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.my_security_group.id]
  subnet_id       = aws_subnet.my_subnet.id

  tags = {
    Name = "aws_ec2_1"
  }
}

resource "aws_instance" "my_aws_instance2" {
  key_name = var.key_pair
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.my_security_group.id]
  subnet_id       = aws_subnet.my_subnet.id

  tags = {
    Name = "aws_ec2_2"
  }
}



// attach public IP to our ec2 instance
resource "aws_eip" "my_aws_eip1" {
  instance = aws_instance.my_aws_instance1.id
  vpc      = true
}
resource "aws_eip" "my_aws_eip2" {
  instance = aws_instance.my_aws_instance2.id
  vpc      = true
}

// route traffic from internet to VPC
resource "aws_internet_gateway" "my_aws_internet_gateway" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "my_aws_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_aws_internet_gateway.id
  }
}

// expose subnet to internet 
resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_aws_route_table.id
}


variable "key_pair" {
  type = string
}

variable "ip_address" {
  type = string
}


output "aws_instance_1_public_ip_and_private_ip" {
  value = "public_ip: ${aws_instance.my_aws_instance1.public_ip} and private_ip: ${aws_instance.my_aws_instance1.private_ip}"
}

output "aws_instance_2_public_ip_and_private_ip" {
  value = "public_ip: ${aws_instance.my_aws_instance2.public_ip} and private_ip: ${aws_instance.my_aws_instance2.private_ip}"
}
