data "aws_partition" "main" {}
data "aws_caller_identity" "main" {}

################################################################################
# Main Function
################################################################################

module "network" {
  source = "./modules/network"
}
