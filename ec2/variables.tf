variable "name" {
  description = "Prefix used for security group names."
  type        = string
}

variable "vpc_id" {
  description = "VPC where the security groups and instances are created."
  type        = string
}

variable "instances" {
  description = "Instance definitions keyed by the desired EC2 Name tag."
  type = map(object({
    role          = string
    subnet_id     = string
    instance_type = string
  }))
}

variable "ssh_key_name" {
  description = "Name of the existing EC2 key pair to attach to all six instances."
  type        = string
}

variable "ssh_ingress_cidrs" {
  description = "IPv4 CIDRs permitted to SSH to the bastion."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to EC2 resources."
  type        = map(string)
  default     = {}
}
