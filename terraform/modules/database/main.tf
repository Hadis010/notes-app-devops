locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# Security group for the private MySQL instance.
# Only the application instances may reach MySQL and SSH (via ProxyJump),
# the database is never exposed publicly.
resource "aws_security_group" "db" {
  name        = "${local.name_prefix}-db-sg"
  description = "Allow MySQL and SSH only from the application instances"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from application instances"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  ingress {
    description     = "SSH from application instances (ProxyJump bastion)"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-db-sg"
  }
}

resource "aws_instance" "db" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.db.id]
  associate_public_ip_address = false
  iam_instance_profile        = var.iam_instance_profile

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "${local.name_prefix}-db"
    Role = "database"
  }
}
