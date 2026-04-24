locals {
  
  azs = keys(var.public_subnets)

  # NAT count logic
  nat_keys = (
    var.nat_mode == "single"   ? ["shared"] :
    var.nat_mode == "regional" ? ["regional"] :
    local.azs
  )
}