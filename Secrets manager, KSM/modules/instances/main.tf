resource "aws_instance" "bastion_instance" {
  ami           = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  subnet_id     = var.public_subnet_id
  associate_public_ip_address = true
  key_name      = var.key_name

  vpc_security_group_ids = [var.bastion_security_group_id]

  user_data = filebase64("${path.module}/install_awscli.sh")

  iam_instance_profile = var.bastion_iam_profile_name

  tags = {
    Name = "Bastion instance"
  }
}