resource "aws_lb" "tf_network_lb" {
  name               = "tf-network-lb"
  load_balancer_type = "network"

  subnet_mapping {
    subnet_id     = module.vpc.public_subnets[0]
    allocation_id = aws_eip.tf_lb_eip.id
  }

  tags = {
    Environment = "dev"
  }
}

# Target groups
resource "aws_lb_target_group" "tf_app_tg" {
  name     = "tf-app-lb-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = module.vpc.vpc_id
}

resource "aws_lb_target_group_attachment" "tf_app_attachment_https" {
  target_group_arn = aws_lb_target_group.tf_app_tg.arn
  target_id        = aws_instance.tf_app_instance.id
  port             = 443
}

# Listener - Zertifikat kann nicht angelegt werden mit TLS
resource "aws_lb_listener" "tf_app_listener" {
  load_balancer_arn = aws_lb.tf_network_lb.arn
  port              = "80"
  protocol          = "TCP"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
  #alpn_policy       = "HTTP2Preferred"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tf_app_tg.arn
  }
}
