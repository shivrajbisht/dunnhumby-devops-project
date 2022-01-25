resource "aws_s3_bucket" "dunnhumby-shivraj-singh-bisht" {
  bucket = "dunnhumby-shivraj-singh-bisht"
  acl    = "public-read"

  tags = {
    Name = "dunnhumby-shivraj-singh-bisht"
  }

}

resource "aws_s3_bucket_public_access_block" "dunnhumby_bucket_access" {
  bucket = aws_s3_bucket.dunnhumby-shivraj-singh-bisht.id

  block_public_acls   = false
  block_public_policy = false
  ignore_public_acls  = false
}


resource "aws_iam_policy" "s3_read_bucket_policy" {
  name        = "s3_read_bucket_policy"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource" : [
          "arn:aws:s3:::*/*",
          "arn:aws:s3:::dunnhumby-shivraj-singh-bisht"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "dunnhumby_role" {
  name = "dunnhumby_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dunnhumby_bucket_policy" {
  role       = aws_iam_role.dunnhumby_role.name
  policy_arn = aws_iam_policy.s3_read_bucket_policy.arn
}

resource "aws_iam_instance_profile" "dunnhumby_profile" {
  name = "dunnhumby-profile"
  role = aws_iam_role.dunnhumby_role.name
}