variable "s3_bucket_id" {
  description = "The id (name) of the S3 bucket used to store the configuration history"
  type        = string
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket used to store the configuration history"
  type        = string
}

variable "create_sns_topic" {
  description = <<-DOC
    Flag to indicate whether an SNS topic should be created for notifications
    If you want to send findings to a new SNS topic, set this to true and provide a valid configuration for subscribers
  DOC

  type    = bool
  default = false
}

variable "subscribers" {
  type = map(object({
    protocol               = string
    endpoint               = string
    endpoint_auto_confirms = bool
  }))
  description = <<-DOC
    A map of subscription configurations for SNS topics
      
    For more information, see:
    https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription#argument-reference
  
    protocol:         
      The protocol to use. The possible values for this are: sqs, sms, lambda, application. (http or https are partially 
      supported, see link) (email is an option but is unsupported in terraform, see link).
    endpoint:         
      The endpoint to send data to, the contents will vary with the protocol. (see link for more information)
    endpoint_auto_confirms:
      Boolean indicating whether the end point is capable of auto confirming subscription e.g., PagerDuty. Default is 
      false
  DOC
  default     = {}
}

variable "findings_notification_arn" {
  description = <<-DOC
    The ARN for an SNS topic to send findings notifications to. This is only used if create_sns_topic is false.
    If you want to send findings to an existing SNS topic, set the value of this to the ARN of the existing topic and set 
    create_sns_topic to false.
  DOC
  default     = null
  type        = string
}


variable "create_iam_role" {
  description = "Flag to indicate whether IAM Roles should be created to grant the proper permissions for AWS Config (affects creation of both the standard Config role, as well as the Organization-wide Aggregator Role (if in use)"

  type        = bool
  default     = false
}

variable "iam_role_arn" {
  description = <<-DOC
    The ARN for an IAM Role AWS Config uses to make read or write requests to the delivery channel and to describe the 
    AWS resources associated with the account. This is only used if create_iam_role is false.
  
    If you want to use an existing IAM Role, set the value of this to the ARN of the existing topic and set 
    create_iam_role to false.
    
    See the AWS Docs for further information: 
    http://docs.aws.amazon.com/config/latest/developerguide/iamrole-permissions.html
  DOC
  default     = null
  type        = string
}

variable "global_resource_collector_region" {
  description = "The region that collects AWS Config data for global resources such as IAM"
  type        = string
}

variable "central_resource_collector_account" {
  description = "The account ID of a central account that will aggregate AWS Config from other accounts"
  type        = string
  default     = null
}

variable "iam_role_organization_aggregator_arn" {
  description = <<-DOC
    The ARN for an IAM Role the Aggregator uses to read organization data
    Should have the AWS-managed policy attached arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations

    This is only used if create_iam_role is false.

    If you want to use an existing IAM Role, set the value of this to the ARN of the existing role and set
    create_iam_role to false.

    See the AWS Docs for further information:
    http://docs.aws.amazon.com/config/latest/developerguide/iamrole-permissions.html
  DOC
  default     = null
  type        = string
}

variable "aggregate_organization_wide" {
  description = <<-DOC
    Whether to configure the central account Aggregator organization-wide,
    using an organization_aggregation_source block.
    Setting this to true will
    - Create an Aggregator (if we're in the AWS Config central account)
    - Create an IAM role for the aggregation with attached AWS-managed policy arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations
    - Enable aggregation for all regions
    - Create an organization_aggregation_source block instead of an account_aggregation_source one

    Note only one of aggregate_organization_wide or child_resource_collector_accounts should be set.

    See:
    https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_aggregator#organization_aggregation_source
  DOC
  type        = bool
  default     = false
}

variable "child_resource_collector_accounts" {
  description = "The account IDs of other accounts that will send their AWS Configuration to this account"
  type        = set(string)
  default     = null
}

variable "force_destroy" {
  type        = bool
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable"
  default     = false
}

variable "managed_rules" {
  description = <<-DOC
    A list of AWS Managed Rules that should be enabled on the account. 

    See the following for a list of possible rules to enable:
    https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html
  DOC
  type = map(object({
    description      = string
    identifier       = string
    input_parameters = any
    tags             = map(string)
    enabled          = bool
  }))
  default = {}
}

variable "s3_key_prefix" {
  type        = string
  description = <<-DOC
    The prefix for AWS Config objects stored in the the S3 bucket. If this variable is set to null, the default, no 
    prefix will be used.
    
    Examples: 
    
    with prefix:    {S3_BUCKET NAME}:/{S3_KEY_PREFIX}/AWSLogs/{ACCOUNT_ID}/Config/*. 
    without prefix: {S3_BUCKET NAME}:/AWSLogs/{ACCOUNT_ID}/Config/*. 
  DOC
  default     = null
}

// Config aggregation isn't enabled for ap-northeast-3, maybe others in the future
// https://docs.aws.amazon.com/config/latest/developerguide/aggregate-data.html
variable "disabled_aggregation_regions" {
  type        = list(string)
  description = "A list of regions where config aggregation is disabled"
  default     = ["ap-northeast-3"]
}
