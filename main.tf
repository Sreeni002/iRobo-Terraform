module "vpc" {
  source = "git::https://github.com/Sreeni002/tf-module-vpc.git"

  for_each = var.vpc
  subnets = each.value["subnets"]
  cidr_block = each.value["cidr_block"]
  tags = local.tags
  env = var.env
}