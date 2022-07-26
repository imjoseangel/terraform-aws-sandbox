################################################################################
# Common Variables
################################################################################
variable "env" {
  type        = string
  description = "Name of the environment."
  default     = "sandbox"
}

variable "region" {
  type        = string
  description = "aws region"
  default     = "eu-central-1"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR"
  default     = "10.100.10.0/24"
}
