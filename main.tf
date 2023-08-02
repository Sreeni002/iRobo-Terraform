module "vpc" {
  source = "git::https://github.com/Sreeni002/tf-module-vpc.git"

  for_each = var.vpc
  cidr_block = each.value["cidr_block"]
  tags = var.tags
}