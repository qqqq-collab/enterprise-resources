resource "aws_iam_policy" "minio-s3" {
  name = "codecov-minio-s3"
  policy = data.aws_iam_policy_document.minio-s3.json
}

data "aws_iam_policy_document" "minio-s3" {
  statement {
    sid = "AllowObjectActions"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.minio.arn}/*"
    ]
  }

  statement {
    sid = "AllowListBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.minio.arn
    ]
  }

  statement {
    sid = "AllowAllS3"
    effect = "Allow"
    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_user" "minio-s3" {
  name = "minio-codecov-enterprise"

  tags = var.resource_tags
}

resource "aws_iam_access_key" "minio-s3" {
  user = aws_iam_user.minio-s3.name
}

resource "aws_iam_user_policy_attachment" "minio-s3" {
  user = aws_iam_user.minio-s3.name
  policy_arn = aws_iam_policy.minio-s3.arn
}

resource "random_pet" "minio-bucket-suffix" {
  length    = "2"
  separator = "-"
}

resource "aws_s3_bucket" "minio" {
  bucket = "codecov-minio-${random_pet.minio-bucket-suffix.id}"
  acl    = "private"

  tags = var.resource_tags
}

resource "kubernetes_secret" "minio-access-key" {
  metadata {
    name = "minio-access-key"
    annotations = var.resource_tags
  }
  data = {
    MINIO_ACCESS_KEY = aws_iam_access_key.minio-s3.id
  }
}

resource "kubernetes_secret" "minio-secret-key" {
  metadata {
    name = "minio-secret-key"
    annotations = var.resource_tags
  }
  data = {
    MINIO_SECRET_KEY = aws_iam_access_key.minio-s3.secret
  }
}
