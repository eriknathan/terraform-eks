variable "project_name" {
  type        = string
  description = "Project Name to be used to name the resources (tags)"
}

variable "tags" {
  type        = map(any)
  description = "Tags to be added to AWS Resources"
}

variable "oidc" {
  type        = string
  description = "HTTPS URL from OIDC provider of the EKS Cluster"
}

variable "cluster_name" {
  type        = string
  description = "EKS Cluster Name"
}

variable "vpcid" {
  type        = string
  description = "EKS Cluster Name"
}