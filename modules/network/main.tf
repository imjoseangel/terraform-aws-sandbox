################################################################################
# Create VPC
################################################################################

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  tags = {
    "Name" = format("%s-vpc", var.env)
  }
}

################################################################################
# Calculate Subnets
################################################################################

data "aws_availability_zones" "main" {
  state = "available"
}

module "subnet_addrs" {
  source  = "hashicorp/subnets/cidr"
  version = "1.0.0"

  base_cidr_block = var.vpc_cidr_block

  networks = [
    {
      name     = data.aws_availability_zones.main.names[0]
      new_bits = 1
    },
    {
      name     = data.aws_availability_zones.main.names[1]
      new_bits = 1
    }
  ]
}

################################################################################
# Create Subnets
################################################################################
resource "aws_subnet" "main" {
  count                   = length(module.subnet_addrs.networks[*].cidr_block)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = module.subnet_addrs.networks[count.index].cidr_block
  availability_zone       = data.aws_availability_zones.main.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = format("%s-vpc", var.env)
    Name = format("%s-vpc-%s", var.env, data.aws_availability_zones.main.names[count.index])
  }
}


################################################################################
# Create Security Group
################################################################################

resource "aws_security_group" "dns" {
  name        = format("sandbox-%s-dns-sg", var.env)
  description = "DNS Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = format("sandbox-%s-dns-sg", var.env)
  }
}

################################################################################
# Create Endpoints
################################################################################

resource "aws_route53_resolver_endpoint" "main" {
  name      = format("sandbox-%s-dns-r53e", var.env)
  direction = "OUTBOUND"

  security_group_ids = [
    aws_security_group.dns.id
  ]

  ip_address {
    subnet_id = aws_subnet.main[0].id
  }

  ip_address {
    subnet_id = aws_subnet.main[1].id
  }

  tags = {
    Name = format("sandbox-%s-dns-r53e", var.env)
  }
}

locals {
  target_domains = [
    "windows.net",
    "azurewebsites.net",
    "azure.com",
    "azure.net",
    "azurecr.io",
    "azmk8s.io"
  ]
}

resource "aws_route53_resolver_rule" "main" {
  count                = length(local.target_domains)
  domain_name          = local.target_domains[count.index]
  name                 = format("sandbox%02d", count.index + 1)
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.main.id

  target_ip {
    ip = "8.8.8.8"
  }

  target_ip {
    ip = "1.1.1.1"
  }
  tags = {
    Name = format("sandbox%02d", count.index + 1)
  }
}

resource "aws_route53_resolver_rule_association" "main" {
  count            = length(local.target_domains)
  resolver_rule_id = aws_route53_resolver_rule.main[count.index].id
  vpc_id           = aws_vpc.main.id
}
