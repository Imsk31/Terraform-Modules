locals {
  final_tags = merge({
    Environment = terraform.workspace
  }, var.tags)
}