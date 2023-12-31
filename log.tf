resource "aws_cloudwatch_log_group" "start_transcription_log_group" {
  name              = "/aws/lambda/${local.function_name.start_transcription}"
  retention_in_days = 3
  skip_destroy      = true
  tags              = local.tags
}