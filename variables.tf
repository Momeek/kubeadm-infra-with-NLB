variable "name" {
  description = "Prefix used for resource names and tags."
  type        = string
  default     = "k8s-kubeadm"
}

variable "aws_region" {
  description = "AWS region for the cluster infrastructure."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "IPv4 CIDR for the VPC. 172.16.1.0/16 is not network-aligned, so use 172.16.0.0/16."
  type        = string
  default     = "172.16.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones keyed as az1 and az2."
  type        = map(string)
  default = {
    az1 = "us-east-1a"
    az2 = "us-east-1b"
  }
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs keyed by availability-zone key."
  type        = map(string)
  default = {
    az1 = "172.16.1.0/24"
    az2 = "172.16.2.0/24"
  }
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs keyed by availability-zone key."
  type        = map(string)
  default = {
    az1 = "172.16.10.0/24"
    az2 = "172.16.11.0/24"
  }
}

variable "bastion_instance_type" {
  description = "EC2 instance type for the public bastion host."
  type        = string
  default     = "t3.micro"
}

variable "control_plane_instance_type" {
  description = "EC2 instance type used by all three control-plane nodes."
  type        = string
  default     = "t3.medium"
}

variable "worker_instance_type" {
  description = "EC2 instance type used by both worker nodes."
  type        = string
  default     = "t3.medium"
}

variable "ssh_key_name" {
  description = "Name of the existing EC2 key pair to attach to all six instances."
  type        = string
  default     = "kubeadm-key"
}

variable "ssh_ingress_cidrs" {
  description = "IPv4 CIDRs permitted to SSH to the bastion. Set this to your trusted public IP in /32 form. Empty means SSH is closed."
  type        = list(string)
  default     = []
}

variable "nlb_internal" {
  description = "Whether the Kubernetes API NLB is internal. False creates an internet-facing NLB in public subnets."
  type        = bool
  default     = false
}

variable "nlb_ingress_cidrs" {
  description = "CIDRs allowed to connect to the Kubernetes API NLB. Set to a trusted public CIDR such as your IP/32; empty blocks listener ingress."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
