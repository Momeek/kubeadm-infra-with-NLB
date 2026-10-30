variable "name" {
  description = "Prefix used for NLB and target group names."
  type        = string
}

variable "vpc_id" {
  description = "VPC containing the NLB and control-plane targets."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets keyed by availability-zone key in which to place the NLB."
  type        = map(string)
}

variable "target_instance_ids" {
  description = "Control-plane instance IDs keyed by node name."
  type        = map(string)
}

variable "target_security_group_ids" {
  description = "Control-plane security group IDs keyed by node name."
  type        = map(string)
}

variable "listener_port" {
  description = "Port exposed by the NLB for the Kubernetes API."
  type        = number
  default     = 6443
}

variable "target_port" {
  description = "Port on each control-plane target."
  type        = number
  default     = 6443
}

variable "internal" {
  description = "Whether the NLB is internal. False creates an internet-facing NLB in public subnets."
  type        = bool
  default     = false
}

variable "ingress_cidrs" {
  description = "CIDRs allowed to reach the NLB listener. Leave empty to block listener ingress until explicitly configured."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to NLB resources."
  type        = map(string)
  default     = {}
}
