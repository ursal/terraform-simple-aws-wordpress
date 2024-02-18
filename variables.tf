variable "region" {
  description = "AWS region to deploy infrastructure"
  type = string
  default = "eu-west-1"
}

variable "instance_type" {
  description = "Default instance type"
  type = string
  default = "t3.micro"
}