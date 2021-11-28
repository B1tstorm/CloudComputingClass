resource "aws_eip" "tf_lb_eip" {
  vpc = true

  tags = {
    "Name" = "tf-vpc-eu-central-1a"
  }
}
resource "aws_eip" "tf_bastion_eip" {
  vpc      = true
  instance = aws_instance.tf_bastion_instance.id

  tags = {
    "Name" = "tf-vpc-eu-central-1a"
  }
}
