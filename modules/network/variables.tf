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
