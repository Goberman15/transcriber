resource "aws_lambda_function" "start_transcription_function" {
  function_name    = local.function_name.start_transcription
  filename         = data.archive_file.start_transcription_asset.output_path
  role             = aws_iam_role.start_transcription_role.arn
  handler          = "Handler"
  source_code_hash = data.archive_file.start_transcription_asset.output_base64sha256
  runtime          = "go1.x"
  timeout          = 90

  depends_on = [aws_cloudwatch_log_group.start_transcription_log_group]
}

data "archive_file" "start_transcription_asset" {
  type        = "zip"
  source_file = "${path.module}/functions/go/start_transcription/Handler"
  output_path = "${path.module}/archive/start_transcription.zip"
}
