module "nat" {
  source = "int128/nat-instance/aws"

  name                        = "main"
  vpc_id                      = var.vpc_id
  public_subnet               = var.subnet_ids[0]
  private_subnets_cidr_blocks = ["172.31.64.0/20", "172.31.96.0/20", "172.31.128.0/20"]
  private_route_table_ids     = ["rtb-04ba05ce6d93af721"]
}

resource "aws_eip" "nat" {
  network_interface = module.nat.eni_id
  tags = {
    "Name" = "nat-instance-main"
  }
}