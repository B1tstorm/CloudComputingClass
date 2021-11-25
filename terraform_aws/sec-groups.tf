# SG -> Bastion
resource "aws_security_group" "dmz-sg" {
  name        = "tf-dmz-sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = module.vpc.vpc_id # <- aus outputs.tf geladen

  ingress {
    description      = "SSH from Internet"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "tf-allow_ssh"
  }
}

# SG -> Webserver (APP)
resource "aws_security_group" "app-sg" {
  name        = "tf-app-sg"
  description = "Allow HTTP/HTTPS, SSH from Bastion inbound traffic"
  vpc_id      = module.vpc.vpc_id # <- aus outputs.tf geladen

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [module.vpc.vpc_cidr_block] # <- aus outputs.tf geladen
  }

    ingress {
    description      = "HTTP from Internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [module.vpc.vpc_cidr_block] # <- aus outputs.tf geladen
  }

  ingress {
    description      = "HTTPS from Internet"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [module.vpc.vpc_cidr_block] # <- aus outputs.tf geladen
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "tf-allow_web_and_ssh"
  }
}

# SG -> RDS Database
resource "aws_security_group" "rds-sg" {
  name        = "tf-rds-sg"
  description = "Allow SQL from Webserver inbound traffic"
  vpc_id      = module.vpc.vpc_id # <- aus outputs.tf geladen

  ingress {
    description      = "SQL from VPC"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = [module.vpc.vpc_cidr_block] # <- aus outputs.tf geladen
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "tf-allow_sql"
  }
}

# SG -> Application-loadbalancer
resource "aws_security_group" "alb-sg" {
  name        = "tf-alb-sg"
  description = "Allow HTTP/HTTPS inbound traffic"
  vpc_id      = module.vpc.vpc_id # <- aus outputs.tf geladen

  ingress {
    description      = "HTTP from Internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTPS from Internet"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "tf-allow_web"
  }
}
