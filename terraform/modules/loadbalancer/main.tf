locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# Security group for the public-facing load balancer VM (software reverse proxy).
resource "aws_security_group" "lb" {
  name        = "${local.name_prefix}-lb-sg"
  description = "Allow public HTTP/HTTPS and admin SSH to the load balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from clients (also used for the ACME challenge)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.ingress_cidr]
  }

  ingress {
    description = "HTTPS from clients"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.ingress_cidr]
  }

  ingress {
    description = "SSH from administration network"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-lb-sg"
  }
}

# Load balancer VM. 
resource "aws_instance" "lb" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.lb.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "${local.name_prefix}-lb"
    Role = "loadbalancer"
  }
}
