variable "public_subnet_id" {
  description = "The ID of the public subnet where the instance will be launched"
  type        = string
}

variable "key_name" {
  description = "The name of the key pair to use for the instance"
  type        = string
}

variable "bastion_security_group_id" {
  description = "The ID of the security group to associate with the instance"
  type        = string
}

variable "bastion_iam_profile_name" {
  description = "The name of the IAM instance profile to associate with the instance"
  type        = string
}