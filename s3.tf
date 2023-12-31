resource "aws_s3_bucket" "transcriber_bucket" {
  bucket = "transcriber-bucket-hsi"

  tags = local.tags
}

resource "aws_s3_bucket_ownership_controls" "transcriber_ownership_ctrl" {
  bucket = aws_s3_bucket.transcriber_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "transcriber_bucket_acl" {
  bucket = aws_s3_bucket.transcriber_bucket.id
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.transcriber_ownership_ctrl]
}

resource "aws_s3_bucket_notification" "s3_trigger_lambda" {
  bucket = aws_s3_bucket.transcriber_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.start_transcription_function.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "audio/"
    filter_suffix       = ".mpeg"
  }

  depends_on = [aws_lambda_permission.s3_trigger_lambda_permisson]
}
