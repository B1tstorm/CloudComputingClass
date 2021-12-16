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
              "Resource": "arn:aws:s3:::mybucket/*"
          },
          {
              "Effect": "Allow",
              "Action": [
                  "s3:PutObject"
              ],
              "Resource": "arn:aws:s3:::mybucket-resized/*"
          }
      ]
 })
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn

}



resource "aws_lambda_function" "test_lambda" {
  filename      = "lambda.py.zip"
  function_name = "lambda_function"
  role    = aws_iam_role.role.arn
  handler = "lambda.lambda_handler"
  source_code_hash = "${base64sha256("lambda.js.zip")}"
  runtime     = "nodejs12.x"
  environment {
    variables = {
      foo = "bar"
    }
  }
}