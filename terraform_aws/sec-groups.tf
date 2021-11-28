# SG -> Bastion (DMZ)
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
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block] # <- aus outputs.tf geladen
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block] # <- aus outputs.tf geladen
  }

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block] # <- aus outputs.tf geladen
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

# SG -> RDS Database (Data)
resource "aws_security_group" "data-sg" {
  name        = "tf-data-sg"
  description = "Allow SQL from Webserver inbound traffic"
  vpc_id      = module.vpc.vpc_id # <- aus outputs.tf geladen

  # Ersetzt durch die ingress Regel: "data-sg-rule"
  # ingress {
  #   description      = "SQL from VPC"
  #   from_port        = 3306
  #   to_port          = 3306
  #   protocol         = "tcp"
  #   cidr_blocks      = [module.vpc.vpc_cidr_block] # <- aus outputs.tf geladen
  # }

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

# ------- Rules ----------
resource "aws_security_group_rule" "data-sg-rule" {
  type      = "ingress"
  from_port = 3306
  to_port   = 3306
  protocol  = "tcp"
  # Wird an die data-sg angebunden
  security_group_id = aws_security_group.data-sg.id
  # Alle mit dieser Securitygroup dürfen von Instanzen mit der Security Group APP kommunizieren
  source_security_group_id = aws_security_group.app-sg.id
}
