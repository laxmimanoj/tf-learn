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

variable "app_sku_tier" {
  default = "Shared"
}

variable "app_sku_size" {
  default = "B1"
}

variable "dotnet_framework_version" {
  default = "v6.0"
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

resource "azurerm_storage_account" "st" {
  name                     = "st${var.workload_name}${var.env}${var.location_tag}01"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.st_type
  account_replication_type = var.st_replication_type
  min_tls_version          = "TLS1_2"
  tags                     = var.tags
}

resource "azurerm_app_service_plan" "plan" {
  name                = "plan-${var.workload_name}-${var.workload_type}-${var.env}-${var.location_tag}-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "FunctionApp"

  sku {
    tier = var.app_sku_tier
    size = var.app_sku_size
  }
  tags = var.tags
}

resource "azurerm_application_insights" "appi" {
  name                = "appi-${var.workload_name}-${var.workload_type}-${var.env}-${var.location_tag}-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  tags                = var.tags
}

resource "azurerm_function_app" "func" {
  name                       = "func-${var.workload_name}-${var.workload_type}-${var.env}-${var.location_tag}-01"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.plan.id
  storage_account_name       = azurerm_storage_account.st.name
  storage_account_access_key = azurerm_storage_account.st.primary_access_key
  https_only                 = true

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.appi.instrumentation_key
  }

  site_config {
    dotnet_framework_version = var.dotnet_framework_version
    always_on                = true
    http2_enabled            = true
  }

  tags = var.tags
}