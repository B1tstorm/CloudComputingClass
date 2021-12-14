module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "project-vpc"
  cidr = "10.10.0.0/16"

  azs             = ["eu-central-1a", "eu-central-1b"]
  private_subnets = ["10.10.1.0/24", "10.10.2.0/24"]
  public_subnets  = ["10.10.0.0/24"]

  # NAT Gateways werden in jedes subnet gepackt und erhalten elastic IP's
  enable_nat_gateway = true
  # Ein einziges NAT Gateway statt in jedem subnet eins & wird im ersten angegeben public subnet angelegt
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


