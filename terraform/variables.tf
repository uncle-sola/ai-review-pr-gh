variable "location" {
  default     = "UK South"
  description = "The location where resources will be created"
}

# variables.tf
variable "environment" {
  description = "Deployment environment (from the GitHub environment name)"
  type        = string
}
