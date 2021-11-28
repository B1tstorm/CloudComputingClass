resource "aws_lb" "tf-network-lb" {
  name               = "tf-network-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = true

  tags = {
    Environment = "dev"
  }
}