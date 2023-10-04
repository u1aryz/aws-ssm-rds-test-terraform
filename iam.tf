# IAMポリシードキュメントの定義
data "aws_iam_policy_document" "ec2_assume_role_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# SSM Managed Coreポリシーの定義
data "aws_iam_policy" "ssm_core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# EC2 SSM IAMロールの作成
resource "aws_iam_role" "ec2_ssm_role" {
  name               = "${var.app_name}-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy_doc.json
}

# SSMポリシーのロールへのアタッチメント
resource "aws_iam_role_policy_attachment" "ssm_attachment" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = data.aws_iam_policy.ssm_core.arn
}

# EC2 SSM IAMインスタンスプロファイルの作成
resource "aws_iam_instance_profile" "ssm_managed_ec2_instance_profile" {
  name = "${var.app_name}-instance-profile"
  role = aws_iam_role.ec2_ssm_role.name
}
