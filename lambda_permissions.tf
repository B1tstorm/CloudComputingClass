resource "aws_iam_role" "parser_role" {
  name = "lambda-parser-role"
  path = "/"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "lambda.amazonaws.com"
          },
          "Effect" : "Allow",
          "Sid" : ""
        }
      ]
  })
}



resource "aws_iam_role" "db_writer_role" {
  name = "lambda-writer-role"
  path = "/"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "lambda.amazonaws.com"
          },
          "Effect" : "Allow",
          "Sid" : ""
        }
      ]
  })
}




#Created Policy for IAM Role
resource "aws_iam_policy" "parser_policy" {
  name        = "lambda-parser-policy"
  description = "A test policy"


  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream"
        ],
        "Resource" : "arn:aws:logs:*:*:*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject"
        ],
        "Resource" : "${aws_s3_bucket.lab6-s3.arn}/*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject"
        ],
        "Resource" : "${aws_s3_bucket.lab6-s3.arn}/*"
      },
      {
        "Effect" : "Allow",
        "Action" : "iam:PassRole",
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "iam:PassedToService" : "lambda.amazonaws.com"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : "lambda:*",
        "Resource" : "*"
      }
    ]
  })
}


#Created Policy for IAM Role
resource "aws_iam_policy" "db_writer_policy" {
  name        = "lambda-writer-policy"
  description = "A test policy"


  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream"
        ],
        "Resource" : "arn:aws:logs:*:*:*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject"
        ],
        "Resource" : "${aws_s3_bucket.lab6-s3.arn}/*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:*"
        ],
        "Resource" : "*"
      }
    ]
  })
}





resource "aws_iam_role_policy_attachment" "parser-policy-attach" {
  role       = aws_iam_role.parser_role.name
  policy_arn = aws_iam_policy.parser_policy.arn
}

resource "aws_iam_role_policy_attachment" "writer-policy-attach" {
  role       = aws_iam_role.db_writer_role.name
  policy_arn = aws_iam_policy.db_writer_policy.arn
}



resource "aws_lambda_permission" "allow_bucket_parser" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.parser-lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.lab6-s3.arn
}

resource "aws_lambda_permission" "allow_bucket_writer" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.db-writer-lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.lab6-s3.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.lab6-s3.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.parser-lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "input/"
    filter_suffix       = ".json"
  }
  depends_on = [
    aws_lambda_permission.allow_bucket_writer,
    aws_lambda_permission.allow_bucket_parser
  ]
}