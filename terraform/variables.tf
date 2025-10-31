variable "environment" {
  type        = string
  default     = "moon"
  description = "The cloud environment"
}

variable "account" {
  type        = string
  default     = "396816018484"
  description = "AWS account the state machine will be deployed in"
}

variable "service_name" {
  type    = string
  default = "cloud-deployment-module"
}

variable "validation_lambda" {
  type    = string
  default = "cdm-authorization-moon"
}

variable "polling_lambda" {
  type    = string
  default = "cdm-authorization-polling-moon"
}

variable "aws_resources_lambda" {
  type    = string
  default = "cdm-aws-resources-moon"
}

variable "gcp_resources_metadata_lambda" {
  type    = string
  default = ""
}

variable "gcp_resources_updates_lambda" {
  type    = string
  default = ""
}

variable "crq_close_lambda" {
  type    = string
  default = "cdm-authorization-closeCRQ-moon"
}

variable "nimbus_cloudformation_sm" {
  type    = string
  default = "arn:aws:states:us-west-2:396816018484:stateMachine:nimbus-nonprod-nimbus-cloudformation"
}
