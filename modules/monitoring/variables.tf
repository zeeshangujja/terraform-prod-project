variable "sns_topic_arn" {
  type = string
}
variable "cluster_arn"          { type = string }
variable "log_group_name"       { type = string }
variable "log_group_arn"        { type = string }
variable "ecr_repository_name"  { type = string }