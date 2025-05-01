data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "assume_role_ec2" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "replication" {
  name               = "iam-replication-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "replication" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]
    resources = [var.main_s3_bucket.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]
    resources = [var.main_s3_bucket.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]
    resources = [var.replica_s3_bucket.arn]
  }
}

resource "aws_iam_policy" "replication" {
  name   = "iam-replication-policy"
  policy = data.aws_iam_policy_document.replication.json
}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
}

resource "aws_s3_bucket_replication_configuration" "replication" {

  role   = aws_iam_role.replication.arn
  bucket = var.main_s3_bucket.id

  rule {
    id     = "replicate-objects"
    status = "Enabled"

    filter {
      prefix = "" # всі об'єкти
    }

    destination {
      bucket        = var.replica_s3_bucket.arn
      storage_class = "STANDARD"
    }

    delete_marker_replication {
      status = "Enabled"
    }
  }
}

data "aws_iam_policy_document" "ListBucket" {
  statement {
    sid      = "ListBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [var.main_s3_bucket.arn]
  }
}

resource "aws_iam_policy" "ListBucket" {
  name   = "iam-ListBucket-policy"
  policy = data.aws_iam_policy_document.ListBucket.json
}

resource "aws_iam_role" "role_for_ec2" {
  name               = "iam-role-for-ec2"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.role_for_ec2.name
  policy_arn = aws_iam_policy.ListBucket.arn
}

resource "aws_iam_instance_profile" "bastion_instance_profile" {
  name = "iam-profile-for-bastion"
  role = aws_iam_role.role_for_ec2.name
}

