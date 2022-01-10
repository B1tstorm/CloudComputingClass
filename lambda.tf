resource "aws_lambda_function" "parser-lambda" {
  filename      = "parser.py.zip"
  function_name = "parser-lambda"
  role          = aws_iam_role.parser_role.arn
  handler       = "parser.lambda_handler"
  runtime       = "python3.8"
  layers        = [aws_lambda_layer_version.lambda-layer.arn]

  environment {
    variables = {
      foo = "bar"
    }
  }
}

resource "aws_lambda_layer_version" "lambda-layer" {
  filename   = "pandas_layer.zip"
  layer_name = "pandas3_8"
  description = "Pandas lib for python3.8"

  compatible_runtimes = ["python3.8"]
}

resource "aws_lambda_function" "db-writer-lambda" {
  filename      = "db-writer.zip"
  function_name = "db-writer-lambda"
  role          = aws_iam_role.db_writer_role.arn
  handler       = "dynamodb.lambda_handler"
  runtime       = "python3.9"
  environment {
    variables = {
      foo = "bar"
    }
  }
}
