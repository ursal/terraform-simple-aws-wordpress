provider "aws" {
  region  = var.region
}

data "aws_caller_identity" "current" {}
data "aws_iam_account_alias" "current" {}
data "aws_region" "current" {}

data "aws_ami" "ubuntu_latest" {
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

resource "aws_instance" "wordpress" {
  ami           = data.aws_ami.ubuntu_latest.id
  instance_type = var.instance_type
  security_groups = [aws_security_group.wordpress-sg.name]

  user_data = file("userdata.sh")

  tags = {
    Name = "wordpress"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [ami]
  }
}

resource "aws_security_group" "wordpress-sg" {
  name = "wordpress-sg"
  description = "Wordpress security group"

  dynamic "ingress" {
    for_each = ["22", "80", "443"]
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}