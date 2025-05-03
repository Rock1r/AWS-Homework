
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

resource "aws_iam_policy" "access_to_secrets" {
  name   = "access-to-secrets"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = var.secret_key_arn
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:ListSecrets"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = var.kms_key_arn
      }
    ]
  })
}


resource "aws_iam_role" "role_for_ec2" {
  name               = "iam-role-for-ec2"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.role_for_ec2.name
  policy_arn = aws_iam_policy.access_to_secrets.arn
}

resource "aws_iam_instance_profile" "bastion_instance_profile" {
  name = "iam-profile-for-bastion"
  role = aws_iam_role.role_for_ec2.name
}

