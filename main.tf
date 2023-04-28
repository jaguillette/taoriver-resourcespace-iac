provider "aws" {
  region  = "us-east-1"
  profile = "personal"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "resource_space" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  associate_public_ip_address = true
  availability_zone = "us-east-1a"
  security_groups = [ aws_security_group.rs_security_group.name ]
  key_name = "rs_key"

  user_data = file("setupResourceSpace.sh")

  tags = {
    Name = "rs_server"
  }
}

resource "aws_ebs_volume" "resource_space_storage" {
  availability_zone = "us-east-1a"
  size              = 125
  final_snapshot    = true
  type              = "sc1"

  tags = {
    Name = "rs_storage"
  }

  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "aws_volume_attachment" "attach_storage" {
  device_name = "/dev/sdh"
  volume_id = aws_ebs_volume.resource_space_storage.id
  instance_id = aws_instance.resource_space.id
}

resource "aws_security_group" "rs_security_group" {
  name = "rs_security_group"
  description = "Allow HTTP and HTTPS traffic to ResourceSpace server"

  ingress {
    description = "Public HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Public HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH access"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Unrestricted outbound access"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "rs_instance_ip" {
  value = aws_instance.resource_space.public_ip
}
