locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# Security group for the application instances.
# Application traffic is only accepted from the load balancer, and SSH is
# restricted to the administration CIDR.
resource "aws_security_group" "app" {
  name        = "${local.name_prefix}-app-sg"
  description = "Allow application traffic from the load balancer and SSH from admins"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Front-end HTTP from the load balancer"
    from_port       = var.front_port
    to_port         = var.front_port
    protocol        = "tcp"
    security_groups = [var.lb_security_group_id]
  }

  ingress {
    description = "SSH from administration network"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  dynamic "ingress" {
    for_each = var.enable_nat_instance && length(var.private_subnet_cidrs) > 0 ? [1] : []

    content {
      description = "NAT forwarding from the private subnets"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = var.private_subnet_cidrs
    }
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-app-sg"
  }
}

# Identical application instances spread across the public subnets.
resource "aws_instance" "app" {
  count = var.instance_count

  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_ids[count.index % length(var.public_subnet_ids)]
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true

  # The first instance doubles as a NAT instance for the private subnets when
  # enabled, so it must not drop traffic it forwards on behalf of the database.
  source_dest_check = var.enable_nat_instance && count.index == 0 ? false : true

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "${local.name_prefix}-app-${count.index + 1}"
    Role = "app"
  }
}
