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

variable "workload" {
  default = "message"
}

variable "app" {
  default = "azlearn"
}

variable "sb_sku" {
  default = "Basic"
}

variable "tags" {
  type = map(string)

  default = {
    created_by = "terraform_cloud"
    workload   = "message"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.workload}-${var.env}-${var.location_tag}-01"
  location = var.location
  tags     = var.tags
}

resource "azurerm_servicebus_namespace" "sb" {
  name                = "sb-${var.app}-${var.env}-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = var.sb_sku

  tags = var.tags
}

resource "azurerm_servicebus_queue" "queue" {
  name         = "sbq-${var.app}-${var.env}-01"
  namespace_id = azurerm_servicebus_namespace.sb.id
}