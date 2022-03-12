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
  default = "db"
}

variable "tags" {
  type = map(string)

  default = {
    created_by    = "terraform_cloud"
    workload_name = "azlearn"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.workload_name}-${var.workload_type}-${var.env}-${var.location_tag}-01"
  location = var.location
  tags     = var.tags
}

resource "azurerm_cosmosdb_account" "db" {
  name                = "cosmos-${var.workload_name}-${var.env}-${var.location_tag}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"
  enable_free_tier    = true

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }

  tags = var.tags
}