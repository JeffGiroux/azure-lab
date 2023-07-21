# Set minimum Terraform version and Terraform Cloud backend
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = ">= 3.66.0"
  }
}
