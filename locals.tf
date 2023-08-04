locals {
  vpc_id = lookup(lookup(module.vpc, "main", null), "vpd_id", null)
  tags = {
    business_unit = "ecommerce"
    business_type = "retail"
    project = "roboshop"
    cost_center = 100
    env = var.env
  }
}
