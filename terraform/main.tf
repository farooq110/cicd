# ------------------------------------------------------------------
# Configure local variables
# ------------------------------------------------------------------

locals {
  sm_template_filepath = "${path.module}/../statemachine/statemachine.json"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "local_file" "sm_template" {
  filename = local.sm_template_filepath
}

# ------------------------------------------------------------------
# Configure AWS Lambda data sources needed for state machine
# ------------------------------------------------------------------

data "aws_lambda_function" "validation_lambda" {
  function_name = var.validation_lambda
}

data "aws_lambda_function" "polling_lambda" {
  function_name = var.polling_lambda
}

data "aws_lambda_function" "aws_resources_lambda" {
  function_name = var.aws_resources_lambda
}

data "aws_lambda_function" "gcp_resources_metadata_lambda" {
  function_name = var.gcp_resources_metadata_lambda
}

data "aws_lambda_function" "gcp_resources_updates_lambda" {
  function_name = var.gcp_resources_updates_lambda
}

data "aws_lambda_function" "crq_close_lambda" {
  function_name = var.crq_close_lambda
}

# ----------------------------------------------------------------------------
# Configure resources for AWS Step Functions definition for Security Config
# ----------------------------------------------------------------------------

# Create an IAM role for the Step Functions state machine
data "aws_iam_policy_document" "state_machine_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "states.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}

resource "aws_iam_role" "state_machine_role" {
  name               = "${var.service_name}-SM-Role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.state_machine_assume_role_policy.json
}

data "aws_iam_policy_document" "state_machine_policy" {
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData",
      "logs:CreateLogDelivery",
      "logs:CreateLogStream",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutLogEvents",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups",
      "events:PutTargets",
      "events:PutRule",
      "events:DescribeRule"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction"
    ]

    resources = [
      "${data.aws_lambda_function.gcp_resources_updates_lambda.arn}",
      "${data.aws_lambda_function.gcp_resources_metadata_lambda.arn}",
      "${data.aws_lambda_function.validation_lambda.arn}",
      "${data.aws_lambda_function.polling_lambda.arn}",
      "${data.aws_lambda_function.aws_resources_lambda.arn}",
      "${data.aws_lambda_function.crq_close_lambda.arn}"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "states:StartExecution",
      "states:ValidateStateMachineDefinition"
    ]

    resources = ["arn:aws:states:*:*:stateMachine:*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "*",
    ]

    resources = ["arn:aws:states:us-west-2:${var.account}:stateMachine:${var.service_name}*"]
  }
}

# Create an IAM policy for the Step Functions state machine
resource "aws_iam_role_policy" "state_machine_role_policy" {
  role   = aws_iam_role.state_machine_role.id
  policy = data.aws_iam_policy_document.state_machine_policy.json
}

resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "${var.service_name}-${var.environment}"
  role_arn = aws_iam_role.state_machine_role.arn
  definition = templatefile(data.local_file.sm_template.filename, {
    gcp_resources_updates_lambda  = "${data.aws_lambda_function.gcp_resources_updates_lambda.arn}",
    gcp_resources_metadata_lambda = "${data.aws_lambda_function.gcp_resources_metadata_lambda.arn}",
    validation_lambda             = "${data.aws_lambda_function.validation_lambda.arn}",
    polling_lambda                = "${data.aws_lambda_function.polling_lambda.arn}",
    aws_resources_lambda          = "${data.aws_lambda_function.aws_resources_lambda.arn}",
    crq_close_lambda              = "${data.aws_lambda_function.crq_close_lambda.arn}",
    nimbus_cloudformation_sm      = "${var.nimbus_cloudformation_sm}"
  })
  depends_on = [
    aws_iam_role_policy.state_machine_role_policy
  ]
}
