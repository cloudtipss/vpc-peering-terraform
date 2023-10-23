provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

module "vpc-a"{
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "vpc-a"

  cidr = "10.0.0.0/16"
  azs  = ["us-east-1a", "us-east-1b"]

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}

module "vpc-b"{
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "vpc-b"

  cidr = "10.1.0.0/16"
  azs  = ["us-east-1a", "us-east-1b"]

  private_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnets  = ["10.1.3.0/24", "10.1.4.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}

resource "aws_security_group" "ssh-a" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = module.vpc-a.vpc_id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ssh-b" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = module.vpc-b.vpc_id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
    content  = tls_private_key.ssh_key.private_key_pem
    filename = "/Users/mykhailozhuravel/Desktop/Blog/website/terraform/vpc-peering/peering/ec2_key.pem"
    file_permission = "0600"
}

resource "aws_key_pair" "public_key" {
  key_name   = "EC2_key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

module "ec2-instance-a" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.5.0"

  name = "Instance-a"
  instance_type = "t3.small"
  subnet_id = module.vpc-a.public_subnets[0]
  associate_public_ip_address = true
  user_data = file("shell-a.sh")

  key_name = aws_key_pair.public_key.key_name
  vpc_security_group_ids = [aws_security_group.ssh-a.id]
}

module "ec2-instance-b" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.5.0"

  name = "Instance-b"
  instance_type = "t3.small"
  subnet_id = module.vpc-b.private_subnets[0]
  associate_public_ip_address = false
  user_data = file("shell-b.sh")

  vpc_security_group_ids = [aws_security_group.ssh-b.id]
}

resource "aws_vpc_peering_connection" "foo" {
  #peer_owner_id = var.peer_owner_id
  peer_vpc_id   = module.vpc-a.vpc_id
  vpc_id        = module.vpc-b.vpc_id
  auto_accept   = true

  tags = {
    Name = "VPC Peering between vpc-a and vpc-b"
  }
}

resource "aws_route" "peering_routes-ab" {
  count                     = length(module.vpc-a.public_route_table_ids)
  route_table_id            = tolist(module.vpc-a.public_route_table_ids)[count.index]
  destination_cidr_block    = module.vpc-b.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.foo.id
}

resource "aws_route" "peering_routes-ba" {
  count                     = length(module.vpc-b.private_route_table_ids)
  route_table_id            = tolist(module.vpc-b.private_route_table_ids)[count.index]
  destination_cidr_block    = module.vpc-a.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.foo.id
}

output "route-a" {
  description = "The public IP address assigned to the instance"
  value       = module.vpc-a.public_route_table_ids
}

output "Connect_to_instance" {
  description = "The public IP address assigned to the instance"
  value       = "ssh -i ${local_file.private_key.filename} ec2-user@${module.ec2-instance-a.public_ip}"
}

