# SG -> Bastion
resource "aws_security_group" "dmz-sg" {
  name        = "dmz-sg"
  description = "Allow HTTP and HTTPS inbound traffic"
  vpc_id      = module.vpc.vpc_id # <- aus outputs.tf geladen

  ingress {
    description      = "HTTPS from Internet"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP from Internet"
    from_port        = 80
    to_port          = 80
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
    Name = "allow_https_http"
  }
}

#die lambda funktionen erlauben keinen inbound trafic (werden von s3 über API getriggert)
# SG -> Lambda's (APP)
resource "aws_security_group" "app-sg" {
  name        = "app-sg"
  description = "a sg for Lambda functions"
  vpc_id      = module.vpc.vpc_id # <- aus outputs.tf geladen

  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "no_inbound_sg"
  }
}

# SG -> RDS Database
resource "aws_security_group" "rds-sg" {
  name        = "rds-sg"
  description = "Allow SQL from app-sg inbound traffic"
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
    Name = "allow_sql"
  }
}


