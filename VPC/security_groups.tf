resource "aws_security_group" "public_sg" {
  name        = "public_sg"
  vpc_id      = aws_vpc.terraform_vpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public_sg"
  }
}

resource "aws_security_group" "private_sg" {
  name        = "private_sg"
  vpc_id      = aws_vpc.terraform_vpc.id

  ingress {
    from_port             = 22
    to_port               = 22
    protocol              = "tcp"
    cidr_blocks           = ["${aws_instance.public_instance.private_ip}/32"] 
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private_sg"
  }

  depends_on = [ aws_instance.public_instance ]
}

