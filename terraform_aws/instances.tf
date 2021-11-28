# NIC -> For subnet
resource "aws_network_interface" "tf_bastion_network_interface" {
  subnet_id       = module.vpc.public_subnets[0]
  private_ips     = ["192.168.0.10"]
  security_groups = [aws_security_group.dmz-sg.id]

  tags = {
    Name = "bastion_network_interface"
  }
}

# NIC -> For subnet
resource "aws_network_interface" "tf_app_network_interface" {
  subnet_id       = module.vpc.private_subnets[0]
  private_ips     = ["192.168.0.100"]
  security_groups = [aws_security_group.app-sg.id]

  tags = {
    Name = "app_network_interface"
  }
}

# Instance –> Amazon Linux 2 AMI (HVM) - Kernel 5.10
resource "aws_instance" "tf_bastion_instance" {
  ami           = "ami-0bd99ef9eccfee250"
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.tf_bastion_network_interface.id
    device_index         = 0
  }

  tags = {
    Name = "tf_bastion_instance"
  }
}

# Instance –> Amazon Linux 2 AMI (HVM) - Kernel 5.10
resource "aws_instance" "tf_app_instance" {
  ami           = "ami-0bd99ef9eccfee250"
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.tf_app_network_interface.id
    device_index         = 0
  }

  tags = {
    Name = "tf_app_instance"
  }
}