variable "subid"{}
provider "azurerm"{
    features {}
    subscription_id = var.subid
}

resource "azurerm_resource_group" "maheshaks" {
  name     = "aksproject"
  location = "West Europe"
}

resource "azurerm_container_registry" "acr" {
  name                = "maheshacr2510" # must be globally unique
  resource_group_name = azurerm_resource_group.maheshaks.name
  location            = azurerm_resource_group.maheshaks.location
  sku                 = "Basic"
  admin_enabled       = false
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "mahesh-aks2510"
  location            = azurerm_resource_group.maheshaks.location
  resource_group_name = azurerm_resource_group.maheshaks.name
  dns_prefix          = "mahesh-aks"

  default_node_pool {
    name       = "nodepool1"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

# output "client_certificate" {
#   value     = azurerm_kubernetes_cluster.example.kube_config[0].client_certificate
#   sensitive = true
# }

# output "kube_config" {
#   value = azurerm_kubernetes_cluster.example.kube_config_raw

#   sensitive = true
# }