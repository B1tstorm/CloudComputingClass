resource "aws_s3_bucket" "target-s3" {
  bucket = "lab6-project-s3-target-oli"
  acl    = "private"
  tags = {
    Name        = "target-s3"
    Environment = "Dev"
  }
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}


resource "aws_s3_bucket" "source-s3" {
  bucket = "lab6-project-s3-source-oli"
  acl    = "private"
  tags = {
    Name        = "source-s3"
    Environment = "Dev"
  }

}