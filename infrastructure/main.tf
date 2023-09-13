terraform {
    backend "azurerm" {
    resource_group_name  = "AUVA"
    storage_account_name = "auvastatefile01"
    container_name       = "terraform"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
    name = var.resource_group_name
}

locals {
    basename = "${var.prefix}${var.basename}${var.suffix}"
}

resource "azurerm_container_registry" "acr" {
  name                = local.basename
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location != null ? var.location : data.azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}


resource "azurerm_kubernetes_cluster" "catupload" {
  name                = local.basename
  location            = var.location != null ? var.location : data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_prefix          = "catupload"

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

// Allow Kubernetes access to ACR
resource "azurerm_role_assignment" "kubernetes_acr_access" {
  principal_id                     = azurerm_kubernetes_cluster.catupload.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

// Store ACR credentials in Key Vault
resource "azurerm_key_vault" "akv" {
  name                        = local.basename
  location                    = var.location != null ? var.location : data.azurerm_resource_group.rg.location
  resource_group_name         = data.azurerm_resource_group.rg.name
  enabled_for_disk_encryption = false
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get","Backup", "Delete", "Set", "List", "Purge", "Recover", "Restore"
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

resource "azurerm_key_vault_secret" "acr_admin_username" {
  name         = "acr-admin-username"
  value        = azurerm_container_registry.acr.admin_username
  key_vault_id = azurerm_key_vault.akv.id
}

resource "azurerm_key_vault_secret" "acr_admin_password" {
  name         = "acr-admin-password"
  value        = azurerm_container_registry.acr.admin_password
  key_vault_id = azurerm_key_vault.akv.id
}
