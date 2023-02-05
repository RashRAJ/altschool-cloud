terraform {
  backend "s3" {
    bucket = "greenbuckettera"
    key    = "statefile.tfstate"
    region = "us-east-1"
  }
}




########################################################################################
##                               Create instance                                      ##
########################################################################################

resource "aws_instance" "instance" {
  count           = length(aws_subnet.my_subnet.*.id)
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = element(aws_subnet.my_subnet.*.id, count.index)
  security_groups = [aws_security_group.sg.id, ]
  key_name        = "mykeypair"

  tags = {
    "Name"        = "Green-Instance-${count.index}"
    "Environment" = "Test"
  }
}


########################################################################################
##                              Create elastic ip                                     ##
########################################################################################

resource "aws_eip" "eip" {
  count            = length(aws_instance.instance.*.id)
  instance         = element(aws_instance.instance.*.id, count.index)
  public_ipv4_pool = "amazon"
  vpc              = true

  tags = {
    "Name" = "EIP-${count.index}"
  }
}

resource "aws_eip_association" "eip_association" {
  count         = length(aws_eip.eip)
  instance_id   = element(aws_instance.instance.*.id, count.index)
  allocation_id = element(aws_eip.eip.*.id, count.index)
}


########################################################################################
##                           Create target group                                      ##
########################################################################################

resource "aws_lb_target_group" "TG" {
  name        = "Green-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.my_vpc.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    healthy_threshold   = 3
    timeout             = 3
    unhealthy_threshold = 3
  }
}


########################################################################################
##                     Create target group attachment                                 ##
########################################################################################


resource "aws_lb_target_group_attachment" "target_reg" {
  count            = length(aws_instance.instance.*.id) == 3 ? 3 : 0
  target_group_arn = aws_lb_target_group.TG.arn
  target_id        = element(aws_instance.instance.*.id, count.index)
  port             = 80
}

########################################################################################
##                          Create listener                                           ##
########################################################################################

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TG.arn
  }
}

########################################################################################
##                          Create load balancer                                      ##
########################################################################################

resource "aws_lb" "lb" {
  name               = "Green-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.my_subnet.*.id


  tags = {
    Environment = "Test"
  }
}


########################################################################################
##                          Configure route 53                                        ##
########################################################################################

resource "aws_route53_zone" "hosted_zone" {
  name = "octoarts.me"
  tags = {
    Environment = "dev"
  }
}



resource "aws_route53_record" "octoarts" {
  name = "octoarts.me"
  zone_id = aws_route53_zone.hosted_zone.zone_id
  type = "A"

  alias {
    name                   = aws_lb.lb.dns_name
    zone_id                = aws_lb.lb.zone_id
    evaluate_target_health = true
  }
}
