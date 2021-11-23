# Instance –> Amazon Linux 2 AMI (HVM) - Kernel 5.10
resource "aws_instance" "tf_bastion_instance" {
  ami           = "ami-0bd99ef9eccfee250"
  instance_type = "t2.micro"

  tags = {
    Name = "tf_bastion-instance"
  }
}

# Instance –> Amazon Linux 2 AMI (HVM) - Kernel 5.10
resource "aws_instance" "tf_app_instance" {
  ami           = "ami-0bd99ef9eccfee250"
  instance_type = "t2.micro"

  tags = {
    Name = "tf_app-instance"
  }
}