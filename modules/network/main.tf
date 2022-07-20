module "network" {
  source              = "github.com/imjoseangel/terraform-aws-privatenat"
  subnet_nat_name     = format("sandbox-%s-nat", var.env)
  subnet_gw_cidr      = []
  subnets_spoke_names = [format("sandbox-%s-vpc-%sa", var.env, var.region), format("sandbox-%s-vpc-%sb", var.env, var.region)]
  igw_name            = format("sandbox-%s-igw", var.env)
  private_nat_name    = format("sandbox-%s-pnat", var.env)
  nateip_name         = format("sandbox-%s-nateip", var.env)
  region              = var.region
}
