resource "azurerm_storage_account" "blob" {
  #checkov:skip=CKV_AZURE_33:Queue service is unused. Classic queue logging is a data-plane call that cannot reach this account (public access and shared keys disabled); queue access is logged via azurerm_monitor_diagnostic_setting.queue instead.
  #checkov:skip=CKV2_AZURE_1:Demo environment holding no sensitive data. Microsoft-managed keys (AES-256) are accepted; a CMK needs a Premium Key Vault and HSM key whose cost and network-access requirements aren't justified here.
  name                     = "${module.naming.convention["storage_account"]}0109x" # Suffix keeps the globally unique name from clashing
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_kind             = "StorageV2"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = false
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true

  sas_policy {
    expiration_period = "00.01:01:00"
  }

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 30
    }

    container_delete_retention_policy {
      days = 30
    }
  }
}

resource "azurerm_storage_container" "blob" {
  #checkov:skip=CKV2_AZURE_21:Checkov only recognises the legacy azurerm_log_analytics_storage_insights, which needs shared keys. Blob read/write/delete logging is configured via azurerm_monitor_diagnostic_setting.blob instead.
  name                  = "documents"
  storage_account_id    = azurerm_storage_account.blob.id
  container_access_type = "private"
}

resource "azurerm_private_endpoint" "blob" {
  name                = "${module.naming.convention["private_endpoint"]}-blob"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.subnet.id

  private_service_connection {
    name                           = "${module.naming.convention["private_endpoint"]}-blob-psc"
    private_connection_resource_id = azurerm_storage_account.blob.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "blob"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }
}

resource "azurerm_monitor_diagnostic_setting" "blob" {
  name                       = "${module.naming.convention["diagnostics"]}-blob"
  target_resource_id         = "${azurerm_storage_account.blob.id}/blobServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }
}

# resource "azurerm_monitor_diagnostic_setting" "queue" {
#   name                       = "diag-queue"
#   target_resource_id         = "${azurerm_storage_account.blob.id}/queueServices/default"
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id

#   enabled_log {
#     category = "StorageRead"
#   }

#   enabled_log {
#     category = "StorageWrite"
#   }

#   enabled_log {
#     category = "StorageDelete"
#   }
# }
