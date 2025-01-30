resource "random_pet" "azurerm_kubernetes_cluster_name" {
  prefix = var.name
}

resource "azurerm_kubernetes_cluster" "k8s" {
  location            = var.region
  name                = random_pet.azurerm_kubernetes_cluster_name.id
  resource_group_name = var.rg
  dns_prefix          = random_pet.azurerm_kubernetes_cluster_name.id

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_D2_v2"
    node_count = 2
  }
  linux_profile {
    admin_username = var.target_user

    ssh_key {
      key_data = tls_private_key.key.public_key_openssh
    }
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
  tags = local.thistagset
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "azurerm_key_vault_secret" "ssh-key" {
  name         = "${var.name}-aks-ssh"
  value        = tls_private_key.key.private_key_openssh
  key_vault_id = var.key_vault_id
  tags = local.thistagset

}

resource "azurerm_key_vault_secret" "ca-cert" {
  name         = "${var.name}-aks-ca"
  value        = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate)
  key_vault_id = var.key_vault_id
  tags = local.thistagset

}

resource "azurerm_key_vault_secret" "client-key" {
  name         = "${var.name}-aks-client-key"
  value        = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_key)
  key_vault_id = var.key_vault_id
  tags = local.thistagset

}

resource "azurerm_key_vault_secret" "client-cert" {
  name         = "${var.name}-aks-client-cert"
  value        = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate)
  key_vault_id = var.key_vault_id
  tags = local.thistagset

}