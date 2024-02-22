locals {
  rds_vars = yamldecode(file("${path.module}/vars/vars.yaml"))
  tags     = merge (lookup(local.rds_vars, "tags", {}))
}

provider "aws" {
  region = "sa-east-1"
}


module "db_rds" {
  for_each    = local.rds_vars.db_instances

  source  = "app.terraform.io/andresantiago/rds/aws"
  version = "1.0.0"

  db_name                   = each.value["db_name"]
  identifier                = each.value["indentifier"]

  engine                    = each.value["engine"]
  engine_version            = each.value["version"]

  username                  = "foo"
  password                  = "foobarbaz"

  instance_class            = each.value["instance_class"]
  storage_type              = "gp2"
  allocated_storage         = each.value["allocated_storage"]
  max_allocated_storage     = each.value["max_allocated_storage"]
  storage_encrypted         = true
  skip_final_snapshot       = true

  customer_owned_ip_enabled = true
  publicly_accessible       = false
  multi_az                  = false
  availability_zone         = local.rds_vars.tags.zone
  vpc_id                    = local.rds_vars.vpc_id
  subnet_ids                = [local.rds_vars.subnet_id]
  security_group_rules      = each.value["security_group"]

  tags                      = local.tags
}