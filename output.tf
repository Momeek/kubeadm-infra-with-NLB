output "vpc_id" {
  description = "ID of the Kubernetes VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs keyed by availability zone."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs keyed by availability zone."
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_id" {
  description = "ID of the single NAT gateway."
  value       = module.vpc.nat_gateway_id
}

output "instance_ids" {
  description = "Instance IDs keyed by the requested node names."
  value       = { for name, instance in module.ec2.instances : name => instance.id }
}

output "instance_private_ips" {
  description = "Private IP addresses keyed by the requested node names."
  value       = { for name, instance in module.ec2.instances : name => instance.private_ip }
}

output "bastion_public_ip" {
  description = "Public IP address of the bastion host."
  value       = module.ec2.instances["bastion-host"].public_ip
}

output "bastion_security_group_id" {
  description = "Security group ID attached to the bastion."
  value       = module.ec2.bastion_security_group_id
}

output "node_security_group_ids" {
  description = "Dedicated security group IDs keyed by control-plane and worker node name."
  value       = module.ec2.node_security_group_ids
}

output "kubernetes_api_nlb_dns_name" {
  description = "DNS name of the Kubernetes API NLB; use with port 6443 as the kubeadm control-plane endpoint."
  value       = module.nlb.nlb_dns_name
}

output "kubernetes_api_nlb_arn" {
  description = "ARN of the Kubernetes API NLB."
  value       = module.nlb.nlb_arn
}
