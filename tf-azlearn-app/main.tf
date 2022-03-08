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
  default = "app"
}

variable "dotnet_framework_version" {
  default = "v6.0"
}

variable "remote_debugging_version" {
  default = "VS2019"
}

variable "app_sku_tier" {
  default = "Shared"
}

variable "app_sku_size" {
  default = "B1"
}

variable "tags" {
  type = map(string)

  default = {
    created_by = "terraform_cloud"
    workload   = "azlearn"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.workload_name}-${var.workload_type}-${var.env}-${var.location_tag}-01"
  location = var.location
  tags     = var.tags
}

resource "azurerm_app_service_plan" "plan" {
  name                = "plan-${var.workload_name}-${var.workload_type}-${var.env}-${var.location_tag}-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Windows"
  reserved            = false

  sku {
    tier = var.app_sku_tier
    size = var.app_sku_size
  }

  tags = var.tags
}

resource "azurerm_app_service" "app" {
  name                = "app-${var.workload_name}-${var.workload_type}-${var.env}-${var.location_tag}-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.plan.id
  https_only          = true

  site_config {
    dotnet_framework_version = var.dotnet_framework_version
    remote_debugging_enabled = true
    remote_debugging_version = var.remote_debugging_version
  }

  tags = var.tags
}