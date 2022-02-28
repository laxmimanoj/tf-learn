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
  default = "prod"
}

variable "location" {
  default = "South Central US"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-azlearn-apps-${var.env}-01"
  location = var.location
  tags = {
    "created_by" = "terraform_cloud"
  }
}

resource "azurerm_app_service_plan" "plan" {
  name                = "plan-azlearn-${var.env}-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Shared"
    size = "B1"
  }

  tags = {
    "created_by" = "terraform_cloud"
  }

}

resource "azurerm_app_service" "app" {
  name                = "app-azlearn-${var.env}-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.plan.id
  https_only          = true

  site_config {
    dotnet_framework_version = "v6.0"
    remote_debugging_enabled = true
    remote_debugging_version = "VS2019"
  }

  tags = {
    "created_by" = "terraform_cloud"
  }
}