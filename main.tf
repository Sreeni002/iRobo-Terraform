module "vpc" {
  source = "git::https://github.com/Sreeni002/tf-module-vpc.git"

  for_each = var.vpc
  subnets = each.value["subnets"]
  cidr_block = each.value["cidr_block"]
  tags = local.tags
  env = var.env
  default_vpc_id = var.default_vpc_id
  default_vpc_cidr = var.default_vpc_cidr
  default_vpc_rtid = var.default_vpc_rtid
}

module "docdb" {
  source = "git::https://github.com/Sreeni002/tf-module-docdb.git"

  for_each = var.docdb
  subnets       = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["subnet_name"], null), "subnet_ids", null)
  allow_db_cidr = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["allow_db_cidr"], null), "subnet_cidrs", null)
  engine_version = each.value["engine_version"]
  instance_count = each.value["instance_count"]
  instance_class = each.value["instance_class"]

  tags = local.tags
  env = var.env
  vpc_id = local.vpc_id
  kms_arn = var.kms_arn
}

module "rds" {
  source = "git::https://github.com/Sreeni002/tf-module-rds.git"

  for_each = var.rds
  subnets       = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["subnet_name"], null), "subnet_ids", null)
  allow_db_cidr = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["allow_db_cidr"], null), "subnet_cidrs", null)
  engine_version = each.value["engine_version"]
  instance_count = each.value["instance_count"]
  instance_class = each.value["instance_class"]

  tags = local.tags
  env = var.env
  vpc_id = local.vpc_id
  kms_arn = var.kms_arn
}

module "elasticache" {
  source = "git::https://github.com/Sreeni002/tf-module-elasticache.git"

  for_each = var.elasticache
  subnets       = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["subnet_name"], null), "subnet_ids", null)
  allow_db_cidr = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["allow_db_cidr"], null), "subnet_cidrs", null)
  engine_version = each.value["engine_version"]
  node_type = each.value["node_type"]
  num_node_groups = each.value["num_node_groups"]
  replicas_per_node_group = each.value["replicas_per_node_group"]

  tags = local.tags
  env = var.env
  vpc_id = local.vpc_id
  kms_arn = var.kms_arn
}

module "rabbitmq" {
  source = "git::https://github.com/Sreeni002/tf-module-amazon-mq.git"

  for_each = var.rabbitmq
  subnets       = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["subnet_name"], null), "subnet_ids", null)
  allow_db_cidr = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["allow_db_cidr"], null), "subnet_cidrs", null)
  instance_type = each.value["instance_type"]

  tags = local.tags
  env = var.env
  vpc_id = local.vpc_id
  kms_arn = var.kms_arn
  bastion_cidr = var.bastion_cidr
}


module "alb" {
  source = "git::https://github.com/Sreeni002/tf-module-alb.git"

  for_each = var.alb
  subnets       = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["subnet_name"], null), "subnet_ids", null)
  allow_alb_cidr = each.value["name"] == "public" ? ["0.0.0.0/0"] : lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["allow_alb_cidr"], null), "subnet_cidrs", null)

  name = each.value["name"]
  internal = each.value["internal"]

  tags = local.tags
  env = var.env
  vpc_id = local.vpc_id
}

module "app" {
  depends_on = [module.vpc,module.docdb,module.elasticache,module.rabbitmq,module.rds,module.alb]
  source = "git::https://github.com/Sreeni002/tf-module-app.git"

  for_each = var.app
  instance_type = each.value["instance_type"]
  name = each.value["name"]
  desired_capacity = each.value["desired_capacity"]
  max_size = each.value["max_size"]
  min_size = each.value["min_size"]
  app_port = each.value["app_port"]
  listener_priority = each.value["listener_priority"]

  subnet_ids = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["subnet_name"], null), "subnet_ids", null)
  vpc_id = lookup(lookup(module.vpc, "main", null), "vpc_id", null)

  allow_app_cidr = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["allow_app_cidr"], null), "subnet_cidrs", null)

  listener_arn = lookup(lookup(module.alb, each.value["lb_type"], null), "listener_arn", null)

  env = var.env
  bastion_cidr = var.bastion_cidr
  tags = local.tags
  domain_name = var.domain_name
}
