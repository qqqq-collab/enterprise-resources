resource "aws_iam_openid_connect_provider" "codecov" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = []
  url             = module.eks.cluster_oidc_issuer_url
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "codecov-eks" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.codecov.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.codecov.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "codecov" {
  name               = "codecov-enterprise-eks"
  assume_role_policy = data.aws_iam_policy_document.codecov-eks.json
}

resource "aws_iam_role_policy_attachment" "minio-s3" {
  role       = aws_iam_role.codecov.name
  policy_arn = aws_iam_policy.minio-s3.arn
}
