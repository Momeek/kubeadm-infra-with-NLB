variable "name" {
  description = "Prefix used for resource names and tags."
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Availability zones keyed by subnet-map key."
  type        = map(string)
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs keyed by availability-zone key."
  type        = map(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs keyed by availability-zone key."
  type        = map(string)
}

variable "tags" {
  description = "Tags applied to VPC resources."
  type        = map(string)
  default     = {}
}
