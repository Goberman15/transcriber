resource "aws_lambda_function" "start_transcription_function" {
  function_name    = local.function_name.start_transcription
  filename         = data.archive_file.start_transcription_asset.output_path
  role             = aws_iam_role.lambda_start_transcription_role.arn
  handler          = "Handler"
  source_code_hash = data.archive_file.start_transcription_asset.output_base64sha256
  runtime          = "go1.x"
  timeout          = 90

  environment {
    variables = {
      transcript_prefix = local.transcript_prefix
    }
  }

  depends_on = [aws_cloudwatch_log_group.start_transcription_log_group]
}

resource "aws_lambda_permission" "s3_trigger_lambda_permisson" {
  statement_id_prefix = "AllowExecutionFromS3Bucket"
  action              = "lambda:InvokeFunction"
  function_name       = aws_lambda_function.start_transcription_function.arn
  principal           = "s3.amazonaws.com"
  source_arn          = aws_s3_bucket.transcriber_bucket.arn

}

data "archive_file" "start_transcription_asset" {
  type        = "zip"
  source_file = "${path.module}/functions/go/start_transcription/Handler"
  output_path = "${path.module}/archive/start_transcription.zip"
}
