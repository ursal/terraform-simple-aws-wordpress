output "data_aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "data_aws_account_alias" {
  value = data.aws_iam_account_alias.current.account_alias
}

output "data_aws_region_name" {
  value = data.aws_region.current.name
}

output "data_aws_region_description" {
  value = data.aws_region.current.description
}

output "wordpress-ip" {
  value = aws_instance.wordpress.public_ip
}