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

resource "azurerm_resource_group" "rg" {
  name     = "rg-azlearn-apps-prod-01"
  location = "South Central US"
  tags = {
    "created_by" = "terraform_cloud"
  }
}

resource "azurerm_app_service_plan" "plan" {
  name                = "plan-azlearn-prod-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Free"
    size = "F1"
  }

  tags = {
    "created_by" = "terraform_cloud"
  }
} 