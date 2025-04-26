resource "aws_instance" "bastion_instance" {
  ami           = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  associate_public_ip_address = true
  key_name      = aws_key_pair.key.key_name

  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "Bastion instance"
  }

  depends_on = [ aws_security_group.bastion_sg, aws_subnet.public, aws_route_table_association.public, aws_internet_gateway.gw, aws_route_table.public_route_table ]
}