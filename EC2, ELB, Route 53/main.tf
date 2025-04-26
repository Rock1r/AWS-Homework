resource "aws_vpc" "terraform_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  
  tags = {
    Name = "terraform_vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "main"
  }
}

resource "aws_eip" "eip" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw, aws_subnet.public, aws_eip.eip, aws_vpc.terraform_vpc]
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key" {
  key_name   = "key"
  public_key = tls_private_key.key.public_key_openssh
}

resource "aws_launch_template" "launch_template" {
  name = "launch_template"

  image_id = "ami-084568db4383264d4"
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.micro"

  key_name = aws_key_pair.key.key_name

  vpc_security_group_ids = [aws_security_group.auto_scale_sg.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "test"
    }
  }

  user_data = filebase64("${path.module}/install_nginx.sh")

  depends_on = [ aws_security_group.auto_scale_sg, aws_key_pair.key, aws_vpc.terraform_vpc]
}

resource "aws_lb_target_group" "lb_target_group" {
  name     = "lb-target-group"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.terraform_vpc.id
  health_check {
    protocol = "TCP"
    port     = 80
    interval = 30
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.elb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}

resource "aws_lb" "elb" {
  name               = "terraform-elb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.elb_sg.id]
  subnets            = [aws_subnet.public.id]

  enable_deletion_protection = false

  tags = {
    Name = "terraform-elb"
  }
}

resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier = [aws_subnet.private.id]

  desired_capacity   = 2
  max_size           = 3
  min_size           = 2

  target_group_arns = [aws_lb_target_group.lb_target_group.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 30

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "asg"
    propagate_at_launch = true
  }

  depends_on = [ aws_nat_gateway.nat, aws_lb.elb, aws_security_group.auto_scale_sg, aws_launch_template.launch_template]
}

resource "aws_route53_zone" "aws_elb_route_pp_ua" {
  name = "aws-elb-route.pp.ua"
  comment = "Route53 zone for pp.ua"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_record" "elb" {
  zone_id = aws_route53_zone.aws_elb_route_pp_ua.zone_id
  name    = "app"
  type    = "CNAME"

  ttl     = 60
  records = [aws_lb.elb.dns_name]
}
