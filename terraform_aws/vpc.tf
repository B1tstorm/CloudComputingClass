module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "tf-vpc"
  cidr = "192.168.0.0/24"

  azs             = ["eu-central-1a"]
  private_subnets = ["192.168.0.64/26", "192.168.0.128/26"]
  public_subnets  = ["192.168.0.0/26"]

  # NAT Gateways werden in jedes subnet gepackt
  enable_nat_gateway = true
  # Ein einziges NAT Gateway statt in jedem subnet & wird im ersten angegeben public subnet angelegt
  single_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}