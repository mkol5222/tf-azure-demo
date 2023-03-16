# resource "azurerm_resource_group" "node-rg" {
#   name     = "${var.resource_group_name}-node"
#   location = var.resource_group_location

#   tags = {
#     environment = "azure-demo"
#   }
# }
resource "azurerm_kubernetes_cluster" "aks" {
  depends_on = [
    azurerm_subnet.aks-subnet
  ]
  name                = "aks1"
  kubernetes_version  = "1.24"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks1"
  node_resource_group = "${var.resource_group_name}-nodes"

  default_node_pool {

    name       = "system"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
    type       = "VirtualMachineScaleSets"
    #availability_zones  = [1, 2, 3]
    enable_auto_scaling = false
    vnet_subnet_id      = azurerm_subnet.aks-subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    # load_balancer_sku = "Standard"
    network_plugin = "azure" # azure (CNI)

  }
  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}

resource "azurerm_route_table" "aks-rt" {
  name                          = "aks-rt-tf"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = false


  route {
    name                   = "to-linux"
    address_prefix         = "10.42.5.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.42.4.4"
  }
  route {
    name                   = "to-internet"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.42.4.4"
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}

resource "azurerm_subnet_route_table_association" "aks-rt-to-subnet" {
  subnet_id      = azurerm_subnet.aks-subnet.id
  route_table_id = azurerm_route_table.aks-rt.id
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw

  sensitive = true
}