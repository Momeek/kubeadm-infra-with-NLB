data "aws_ssm_parameter" "ubuntu_2204_ami" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

resource "aws_security_group" "bastion" {
  name        = "${var.name}-bastion-sg"
  description = "SSH access to the public bastion host."
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ssh_ingress_cidrs
    content {
      description = "SSH from an approved administrator CIDR."
      from_port   = 22
      to_port     = 22
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

  tags = merge(var.tags, { Name = "${var.name}-bastion-sg" })
}

resource "aws_security_group" "control_plane1" {
  name        = "${var.name}-control-plane1-sg"
  description = "Dedicated security group for control-plane1."
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-control-plane1-sg" })
}

resource "aws_security_group" "control_plane2" {
  name        = "${var.name}-control-plane2-sg"
  description = "Dedicated security group for control-plane2."
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-control-plane2-sg" })
}

resource "aws_security_group" "control_plane3" {
  name        = "${var.name}-control-plane3-sg"
  description = "Dedicated security group for control-plane3."
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-control-plane3-sg" })
}

resource "aws_security_group" "worker_node1" {
  name        = "${var.name}-worker-node1-sg"
  description = "Dedicated security group for worker-node1."
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-worker-node1-sg" })
}

resource "aws_security_group" "worker_node2" {
  name        = "${var.name}-worker-node2-sg"
  description = "Dedicated security group for worker-node2."
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-worker-node2-sg" })
}

locals {
  node_security_group_ids = {
    "control-plane1" = aws_security_group.control_plane1.id
    "control-plane2" = aws_security_group.control_plane2.id
    "control-plane3" = aws_security_group.control_plane3.id
    "worker-node1"   = aws_security_group.worker_node1.id
    "worker-node2"   = aws_security_group.worker_node2.id
  }

  node_to_node_pairs = {
    for pair in setproduct(keys(local.node_security_group_ids), keys(local.node_security_group_ids)) :
    "${pair[0]}-from-${pair[1]}" => {
      target = local.node_security_group_ids[pair[0]]
      source = local.node_security_group_ids[pair[1]]
    }
  }

  bastion_ssh_targets = {
    for name, security_group_id in local.node_security_group_ids : name => security_group_id
  }

  control_plane_security_group_ids = {
    "control-plane1" = aws_security_group.control_plane1.id
    "control-plane2" = aws_security_group.control_plane2.id
    "control-plane3" = aws_security_group.control_plane3.id
  }
}

resource "aws_vpc_security_group_ingress_rule" "node_to_node" {
  for_each = local.node_to_node_pairs

  security_group_id            = each.value.target
  referenced_security_group_id = each.value.source
  ip_protocol                  = "-1"
  description                  = "Kubernetes cluster traffic between ${each.key}."
}

resource "aws_vpc_security_group_ingress_rule" "bastion_ssh_to_nodes" {
  for_each = local.bastion_ssh_targets

  security_group_id            = each.value
  referenced_security_group_id = aws_security_group.bastion.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  description                  = "SSH from the bastion to ${each.key}."
}

resource "aws_vpc_security_group_ingress_rule" "bastion_api_to_control_planes" {
  for_each = local.control_plane_security_group_ids

  security_group_id            = each.value
  referenced_security_group_id = aws_security_group.bastion.id
  ip_protocol                  = "tcp"
  from_port                    = 6443
  to_port                      = 6443
  description                  = "Kubernetes API access from the bastion to ${each.key}."
}

resource "aws_instance" "bastion_host" {
  ami                         = data.aws_ssm_parameter.ubuntu_2204_ami.value
  instance_type               = var.instances["bastion-host"].instance_type
  subnet_id                   = var.instances["bastion-host"].subnet_id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  key_name                    = var.ssh_key_name
  associate_public_ip_address = true

  root_block_device {
    encrypted             = true
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = merge(var.tags, { Name = "bastion-host", Role = "bastion" })
}

resource "aws_instance" "control_plane1" {
  ami                         = data.aws_ssm_parameter.ubuntu_2204_ami.value
  instance_type               = var.instances["control-plane1"].instance_type
  subnet_id                   = var.instances["control-plane1"].subnet_id
  vpc_security_group_ids      = [aws_security_group.control_plane1.id]
  key_name                    = var.ssh_key_name
  associate_public_ip_address = false

  root_block_device {
    encrypted             = true
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = merge(var.tags, { Name = "control-plane1", Role = "control-plane" })
}

resource "aws_instance" "control_plane2" {
  ami                         = data.aws_ssm_parameter.ubuntu_2204_ami.value
  instance_type               = var.instances["control-plane2"].instance_type
  subnet_id                   = var.instances["control-plane2"].subnet_id
  vpc_security_group_ids      = [aws_security_group.control_plane2.id]
  key_name                    = var.ssh_key_name
  associate_public_ip_address = false

  root_block_device {
    encrypted             = true
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = merge(var.tags, { Name = "control-plane2", Role = "control-plane" })
}

resource "aws_instance" "control_plane3" {
  ami                         = data.aws_ssm_parameter.ubuntu_2204_ami.value
  instance_type               = var.instances["control-plane3"].instance_type
  subnet_id                   = var.instances["control-plane3"].subnet_id
  vpc_security_group_ids      = [aws_security_group.control_plane3.id]
  key_name                    = var.ssh_key_name
  associate_public_ip_address = false

  root_block_device {
    encrypted             = true
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = merge(var.tags, { Name = "control-plane3", Role = "control-plane" })
}

resource "aws_instance" "worker_node1" {
  ami                         = data.aws_ssm_parameter.ubuntu_2204_ami.value
  instance_type               = var.instances["worker-node1"].instance_type
  subnet_id                   = var.instances["worker-node1"].subnet_id
  vpc_security_group_ids      = [aws_security_group.worker_node1.id]
  key_name                    = var.ssh_key_name
  associate_public_ip_address = false

  root_block_device {
    encrypted             = true
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = merge(var.tags, { Name = "worker-node1", Role = "worker" })
}

resource "aws_instance" "worker_node2" {
  ami                         = data.aws_ssm_parameter.ubuntu_2204_ami.value
  instance_type               = var.instances["worker-node2"].instance_type
  subnet_id                   = var.instances["worker-node2"].subnet_id
  vpc_security_group_ids      = [aws_security_group.worker_node2.id]
  key_name                    = var.ssh_key_name
  associate_public_ip_address = false

  root_block_device {
    encrypted             = true
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = merge(var.tags, { Name = "worker-node2", Role = "worker" })
}
