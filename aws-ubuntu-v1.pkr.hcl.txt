# packer block
packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}


source "amazon-ebs" "tutorial_ubuntu" {
  ami_name      = "aws-ubuntu-v2"
  instance_type = "t2.micro"
  # profile: name des profils in der ~/.aws/credentials Datei.
  profile       = "default"
  region        = "eu-central-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  # ssh_username allows packer to ssh into the ec2 to configure it
  ssh_username = "ubuntu"
}
# die Source beim build ist der zusammengesetzte Name von oben bei source
build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.tutorial_ubuntu"
  ]

provisioner "shell" {
  environment_vars = [
    "CC=hello cloud computing",
  ]
  # -y flag prevents waiting for user input
  inline = [
    "sudo apt-get update",
    "sudo apt-get upgrade",
    "sudo apt-get install -y nginx",
    "echo \"CC is $CC\" > example.txt",
    "echo \"nginx has been installed\""
  ]
}

provisioner "file" {
  source = "./index.html"
  destination = "/tmp/index.html"
}

provisioner "shell" {
  inline = [
    "sudo mv /tmp/index.html /var/www/html"
  ]
}


}

