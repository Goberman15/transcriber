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
