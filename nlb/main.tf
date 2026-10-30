resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "Controls access to the Kubernetes API Network Load Balancer."
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_cidrs
    content {
      description = "Kubernetes API access from an approved CIDR."
      from_port   = var.listener_port
      to_port     = var.listener_port
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "control_plane_api_from_nlb" {
  for_each = var.target_security_group_ids

  security_group_id            = each.value
  referenced_security_group_id = aws_security_group.this.id
  ip_protocol                  = "tcp"
  from_port                    = var.target_port
  to_port                      = var.target_port
  description                  = "Kubernetes API traffic from the NLB to ${each.key}."
}

resource "aws_lb" "this" {
  name               = "${var.name}-nlb"
  internal           = var.internal
  load_balancer_type = "network"
  subnets            = values(var.subnet_ids)
  security_groups    = [aws_security_group.this.id]

  enable_cross_zone_load_balancing = true

  tags = merge(var.tags, { Name = "${var.name}-nlb" })
}

resource "aws_lb_target_group" "api" {
  name        = "${var.name}-api-tg"
  port        = var.target_port
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    enabled  = true
    protocol = "TCP"
    port     = "traffic-port"
  }

  tags = merge(var.tags, { Name = "${var.name}-api-tg" })
}

resource "aws_lb_listener" "api" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

resource "aws_lb_target_group_attachment" "control_plane" {
  for_each = var.target_instance_ids

  target_group_arn = aws_lb_target_group.api.arn
  target_id        = each.value
  port             = var.target_port
}
