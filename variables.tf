variable "cidr_block" {
  type        = string
  description = "Network CIDR block to be used for the VPC"
}

variable "project_name" {
  type        = string
  description = "Project Name to be used to name the resources (tags)"
}

variable "region" {
  type        = string
  description = "AWS region to create the resources"
}

variable "tags" {
  type        = map(any)
  description = "A map of tags to add to all AWS Resources"
}