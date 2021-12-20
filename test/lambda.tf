resource "aws_iam_role" "role" {
  name = "my-test-role"
  path = "/"

  assume_role_policy = jsonencode(
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  })
}




#Created Policy for IAM Role
resource "aws_iam_policy" "policy" {
  name        = "my-test-policy"
  description = "A test policy"


  policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": [
                  "logs:PutLogEvents",
                  "logs:CreateLogGroup",
                  "logs:CreateLogStream"
              ],
              "Resource": "arn:aws:logs:*:*:*"
          },
          {
              "Effect": "Allow",
              "Action": [
                  "s3:GetObject"
              ],
              "Resource": "arn:aws:s3:::${aws_s3_bucket.source-s3.bucket}/*"
          },
          {
              "Effect": "Allow",
              "Action": [
                  "s3:PutObject"
              ],
              "Resource": "${aws_s3_bucket.target-s3.arn}/*"
          }
      ]
 })
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn

}



resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.parser-lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.source-s3.arn
}


resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.source-s3.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.parser-lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}


resource "aws_lambda_function" "parser-lambda" {
  filename      = "parser.zip"
  function_name = "parser-lambda"
  role    = aws_iam_role.role.arn
  handler = "parser.lambda_handler"
  runtime     = "python3.9"
  environment {
    variables = {
      foo = "bar"
    }
  }
}