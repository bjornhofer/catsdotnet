output "azurerm_kubernetes_cluster" {
  value = azurerm_kubernetes_cluster.catupload.name
}

output "azurerm_container_registry" {
  value = azurerm_container_registry.acr.name
}