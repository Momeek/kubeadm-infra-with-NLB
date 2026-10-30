output "nlb_arn" {
  description = "ARN of the Kubernetes API Network Load Balancer."
  value       = aws_lb.this.arn
}

output "nlb_dns_name" {
  description = "DNS name to use as the Kubernetes API endpoint."
  value       = aws_lb.this.dns_name
}

output "nlb_zone_id" {
  description = "Route 53 hosted zone ID associated with the NLB."
  value       = aws_lb.this.zone_id
}

output "target_group_arn" {
  description = "ARN of the control-plane target group."
  value       = aws_lb_target_group.api.arn
}

output "security_group_id" {
  description = "Security group ID attached to the NLB."
  value       = aws_security_group.this.id
}
