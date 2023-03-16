
module "nat" {
  source                      = "int128/nat-instance/aws"
  name                        = "main"
  vpc_id                      = var.vpc_id
  public_subnet               = var.subnet_ids[0]
  private_subnets_cidr_blocks = var.private_subnet_cidrs
  private_route_table_ids     = var.private_route_table_ids
  count                       = var.nat_enabled
}

resource "aws_eip" "nat" {
  network_interface = module.nat[0].eni_id
  count             = var.nat_enabled
  tags = {
    "Name" = "nat-instance-main"
  }
}