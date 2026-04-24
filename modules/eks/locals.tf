locals {
  cluster_sg_rules = {
    node_to_cluster = {
      type      = "ingress"
      from_port = 443
      to_port   = 443
      protocol  = "tcp"

      cidr_blocks = null
      self        = false
      source_sg   = "node"
    }

    cluster_internal = {
      type      = "ingress"
      from_port = 0
      to_port   = 65535
      protocol  = "tcp"

      cidr_blocks = null
      self        = true
      source_sg   = null
    }

    egress_all = {
      type      = "egress"
      from_port = 0
      to_port   = 0
      protocol  = "-1"

      cidr_blocks = ["0.0.0.0/0"]
      self        = false
      source_sg   = null
    }
  }

  node_sg_rules = {
    cluster_to_node = {
      type      = "ingress"
      from_port = 0
      to_port   = 65535
      protocol  = "tcp"

      cidr_blocks = null
      self        = false
      source_sg   = "cluster"
    }

    node_internal = {
      type      = "ingress"
      from_port = 0
      to_port   = 65535
      protocol  = "tcp"

      cidr_blocks = null
      self        = true
      source_sg   = null
    }

    lb_to_node = {
      type      = "ingress"
      from_port = 30000
      to_port   = 32767
      protocol  = "tcp"

      cidr_blocks = null
      self        = false
      source_sg   = "lb"
    }

    node_egress = {
      type      = "egress"
      from_port = 0
      to_port   = 0
      protocol  = "-1"

      cidr_blocks = ["0.0.0.0/0"]
      self        = false
      source_sg   = null
    }
  }

  lb_sg_rules = {
    http_in = {
      type      = "ingress"
      from_port = 80
      to_port   = 80
      protocol  = "tcp"

      cidr_blocks = ["0.0.0.0/0"]
      self        = false
      source_sg   = null
    }

    https_in = {
      type      = "ingress"
      from_port = 443
      to_port   = 443
      protocol  = "tcp"

      cidr_blocks = ["0.0.0.0/0"]
      self        = false
      source_sg   = null
    }

    lb_to_node = {
      type      = "egress"
      from_port = 30000
      to_port   = 32767
      protocol  = "tcp"

      cidr_blocks = null
      self        = false
      source_sg   = "node"
    }
  }
}