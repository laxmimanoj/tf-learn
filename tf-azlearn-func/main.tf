terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.98.0"
    }
  }
}

provider "azurerm" {
  features {

  }
}

variable "env" {
  default = "dev"
}

variable "location" {
  default = "South Central US"
}

variable "location_tag" {
  default = "scus"
}

variable "workload_name" {
  default = "azlearn"
}

variable "workload_type" {
  default = "func"
}

variable "st_type" {
  default = "Standard"
}

variable "st_replication_type" {
  default = "LRS"
}

variable "tags" {
  type = map(string)

  default = {
    created_by    = "terraform_cloud"
    workload_name = "azlearn"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.workload_name}-app-${var.env}-${var.location_tag}-01"
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "st" {
  name                     = "st${var.workload_name}${var.env}01"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.st_type
  account_replication_type = var.st_replication_type
  tags                     = var.tags
}