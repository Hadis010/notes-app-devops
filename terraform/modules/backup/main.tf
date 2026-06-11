locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "backups" {
  bucket = "${local.name_prefix}-backups-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "${local.name_prefix}-backups"
  }
}

resource "aws_s3_bucket_public_access_block" "backups" {
  bucket = aws_s3_bucket.backups.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "backups" {
  bucket = aws_s3_bucket.backups.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backups" {
  bucket = aws_s3_bucket.backups.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "backups" {
  bucket = aws_s3_bucket.backups.id

  rule {
    id     = "expire-old-backups"
    status = "Enabled"

    filter {}

    expiration {
      days = var.retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = var.retention_days
    }
  }

  depends_on = [aws_s3_bucket_versioning.backups]
}

data "aws_iam_policy_document" "backup_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "backup" {
  name               = "${local.name_prefix}-db-backup-role"
  assume_role_policy = data.aws_iam_policy_document.backup_assume.json

  tags = {
    Name = "${local.name_prefix}-db-backup-role"
  }
}

data "aws_iam_policy_document" "backup" {
  statement {
    sid       = "ListBackupBucket"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.backups.arn]
  }

  statement {
    sid       = "ReadWriteBackups"
    actions   = ["s3:PutObject", "s3:GetObject"]
    resources = ["${aws_s3_bucket.backups.arn}/*"]
  }
}

resource "aws_iam_policy" "backup" {
  name   = "${local.name_prefix}-db-backup-policy"
  policy = data.aws_iam_policy_document.backup.json
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = aws_iam_policy.backup.arn
}

resource "aws_iam_instance_profile" "backup" {
  name = "${local.name_prefix}-db-backup-profile"
  role = aws_iam_role.backup.name
}
