# -----------------------------
# SECURITY GROUPS
# -----------------------------
resource "aws_security_group" "cluster_sg" {
  name   = "${var.cluster_name}-cluster-sg"
  vpc_id = var.vpc_id
  tags   = var.tags
}

resource "aws_security_group" "node_sg" {
  name   = "${var.cluster_name}-node-sg"
  vpc_id = var.vpc_id
  tags   = var.tags
}

resource "aws_security_group" "lb_sg" {
  name   = "${var.cluster_name}-lb-sg"
  vpc_id = var.vpc_id
  tags   = var.tags
}

# -----------------------------
# CLUSTER SG RULES
# -----------------------------
resource "aws_security_group_rule" "cluster_rules" {
  for_each = local.cluster_sg_rules

  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  security_group_id = aws_security_group.cluster_sg.id

  cidr_blocks = each.value.cidr_blocks != null ? each.value.cidr_blocks : null
  self        = each.value.self == true ? true : null

  source_security_group_id = (
    each.value.source_sg == "node" ? aws_security_group.node_sg.id : null
  )
}

# -----------------------------
# NODE SG RULES
# -----------------------------
resource "aws_security_group_rule" "node_rules" {
  for_each = local.node_sg_rules

  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  security_group_id = aws_security_group.node_sg.id

  cidr_blocks = each.value.cidr_blocks != null ? each.value.cidr_blocks : null
  self        = each.value.self == true ? true : null

  source_security_group_id = (
    each.value.source_sg == "cluster" ? aws_security_group.cluster_sg.id :
    each.value.source_sg == "lb" ? aws_security_group.lb_sg.id :
    null
  )
}

resource "aws_security_group_rule" "cluster_admin_access" {
  for_each = { for idx, sg in var.allowed_sg_ids : idx => sg }

  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster_sg.id
  source_security_group_id = each.value
}

# -----------------------------
# LB SG RULES
# -----------------------------
resource "aws_security_group_rule" "lb_rules" {
  for_each = local.lb_sg_rules

  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  security_group_id = aws_security_group.lb_sg.id

  cidr_blocks = each.value.cidr_blocks != null ? each.value.cidr_blocks : null

  source_security_group_id = (
    each.value.source_sg == "node" ? aws_security_group.node_sg.id : null
  )
}