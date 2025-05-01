output "bastion_iam_profile_name"{
    description = "The IAM profile for the bastion instance"
    value       = aws_iam_instance_profile.bastion_instance_profile.name
}