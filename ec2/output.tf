output "instances" {
  description = "Instance IDs, addresses, and availability zones keyed by instance name."
  value = {
    "bastion-host" = {
      id                = aws_instance.bastion_host.id
      private_ip        = aws_instance.bastion_host.private_ip
      public_ip         = aws_instance.bastion_host.public_ip
      availability_zone = aws_instance.bastion_host.availability_zone
    }
    "control-plane1" = {
      id                = aws_instance.control_plane1.id
      private_ip        = aws_instance.control_plane1.private_ip
      public_ip         = aws_instance.control_plane1.public_ip
      availability_zone = aws_instance.control_plane1.availability_zone
    }
    "control-plane2" = {
      id                = aws_instance.control_plane2.id
      private_ip        = aws_instance.control_plane2.private_ip
      public_ip         = aws_instance.control_plane2.public_ip
      availability_zone = aws_instance.control_plane2.availability_zone
    }
    "control-plane3" = {
      id                = aws_instance.control_plane3.id
      private_ip        = aws_instance.control_plane3.private_ip
      public_ip         = aws_instance.control_plane3.public_ip
      availability_zone = aws_instance.control_plane3.availability_zone
    }
    "worker-node1" = {
      id                = aws_instance.worker_node1.id
      private_ip        = aws_instance.worker_node1.private_ip
      public_ip         = aws_instance.worker_node1.public_ip
      availability_zone = aws_instance.worker_node1.availability_zone
    }
    "worker-node2" = {
      id                = aws_instance.worker_node2.id
      private_ip        = aws_instance.worker_node2.private_ip
      public_ip         = aws_instance.worker_node2.public_ip
      availability_zone = aws_instance.worker_node2.availability_zone
    }
  }
}

output "bastion_security_group_id" {
  description = "Security group ID attached to the bastion."
  value       = aws_security_group.bastion.id
}

output "node_security_group_ids" {
  description = "Dedicated security group IDs keyed by control-plane and worker node name."
  value       = local.node_security_group_ids
}
