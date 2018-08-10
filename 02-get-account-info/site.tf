data "aws_caller_identity" "current" {}

data "aws_iam_account_alias" "current" {}

output "aws_account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

output "aws_account_name" {
  value = "${data.aws_iam_account_alias.current.account_alias}"
}
