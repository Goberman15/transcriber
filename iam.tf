resource "aws_iam_policy" "read_s3_policy" {
  name   = "read_s3_policy_010124"
  policy = data.aws_iam_policy_document.write_s3_policy_document.json
  tags   = local.tags
}

data "aws_iam_policy_document" "write_s3_policy_document" {
  statement {
    sid    = "LambdaWriteS3Policy010124"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:putObject"
    ]
    resources = [
      "${aws_s3_bucket.transcriber_bucket.arn}/",
      "${aws_s3_bucket.transcriber_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "start_transcription_policy" {
  name   = "start_transcription_policy_010124"
  policy = data.aws_iam_policy_document.start_transcription_policy_document.json
  tags   = local.tags
}

data "aws_iam_policy_document" "start_transcription_policy_document" {
  statement {
    sid    = "LambdaStartTranscriptionJob010124"
    effect = "Allow"
    actions = [
      "transcribe:StartTranscriptionJob"
    ]
    resources = ["*"]
  }
}

# resource "aws_iam_policy" "delete_s3_policy" {
#   name   = "delete_s3_policy_010124"
#   policy = data.aws_iam_policy_document.delete_s3_policy.json
# }

# data "aws_iam_policy_document" "delete_s3_policy" {
#   statement {
#     sid    = "LambdaDeleteS3ObjectPolicy010124"
#     effect = "Allow"
#     actions = [
#       "s3:DeleteObject"
#     ]
#     resources = [
#       "${aws_s3_bucket.transcriber_bucket.arn}/",
#       "${aws_s3_bucket.transcriber_bucket.arn}/*"
#     ]
#   }
# }

resource "aws_iam_role" "lambda_start_transcription_role" {
  name               = "lambda_start_transcription_role_010124"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy_document.json

  managed_policy_arns = [
    aws_iam_policy.read_s3_policy.arn,
    aws_iam_policy.start_transcription_policy.arn,
    data.aws_iam_policy.lambda_basic_execution_role.arn
  ]

  tags = local.tags
}

data "aws_iam_policy" "lambda_basic_execution_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "lambda_assume_role_policy_document" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}
