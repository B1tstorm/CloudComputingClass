resource "aws_s3_bucket" "lab6-s3" {
  bucket = "lab6-project-s3"
  acl    = "private"
  tags = {
    Name        = "lab6-s3"
    Environment = "Dev"
  }
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}
