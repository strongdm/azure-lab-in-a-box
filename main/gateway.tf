/*
 * StrongDM Gateway resources
 * This file defines resources for the StrongDM gateway which serves as the connection point for 
 * clients accessing resources in the lab environment.
 */

// Public IP for the StrongDM Gateway to allow inbound connections from clients
resource "azurerm_public_ip" "sdm-gw-ip" {
  name                = "${var.name}-sdmgw-public-ip"
  location            = var.region
  resource_group_name = coalesce(var.rg, one(module.rg[*].rgname))
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "${var.name}sdmgw"
}

// Network interface for the StrongDM Gateway with public IP attached
resource "azurerm_network_interface" "sdm-gw-nic" {
  name                = "${var.name}-sdmgw-nic"
  location            = var.region
  resource_group_name = coalesce(var.rg, one(module.rg[*].rgname))

  ip_configuration {
    name                          = "internal"
    subnet_id                     = coalesce(var.gateway_subnet, one(module.network[*].gateway_subnet))
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.sdm-gw-ip.id
  }
  tags = merge(var.tagset, {
    network = "Public"
    class   = "sdminfra"
  })
}

// StrongDM Gateway node definition that registers with the StrongDM control plane
resource "sdm_node" "gateway" {
  gateway {
    name           = var.strongdm_naming.gateway_prefix
    listen_address = "${azurerm_public_ip.sdm-gw-ip.ip_address}:${local.strongdm_gateway_port}"
    bind_address   = "0.0.0.0:${local.strongdm_gateway_port}"
    tags = merge(var.tagset, {
      network = "Public"
      class   = "sdminfra"
      "eng__${var.name}AD" = "true"
    })
  }
}

// SSH access resource for the Gateway VM itself (for administrative purposes)
resource "sdm_resource" "ssh-gateway" {
  ssh {
    name     = "${var.name}-sdm-gateway"
    hostname = azurerm_network_interface.sdm-gw-nic.private_ip_address
    username = var.admin_usernames.linux_admin
    port     = var.service_ports.ssh
    tags = merge(var.tagset, {
      network = "Public"
      class   = "sdminfra"
    })

  }
}

resource "azurerm_linux_virtual_machine" "sdmgw" {
  name                  = "${var.name}-sdmgw01"
  resource_group_name   = coalesce(var.rg, one(module.rg[*].rgname))
  location              = var.region
  size                  = var.vm_sizes.gateway
  network_interface_ids = [azurerm_network_interface.sdm-gw-nic.id]

  user_data = base64encode(templatefile("${path.module}/gw-provision.tpl", {
    sdm_relay_token       = sdm_node.gateway.gateway[0].token
    target_user           = "azureuser"
    vault_ip              = ""
    sdm_domain            = data.env_var.sdm_api.value == "" ? "" : coalesce(join(".", slice(split(".", element(split(":", data.env_var.sdm_api.value), 0)), 1, length(split(".", element(split(":", data.env_var.sdm_api.value), 0))))), "")
    azure_tenant_id       = data.azurerm_client_config.current.tenant_id
    azure_subscription_id = data.azurerm_subscription.subscription.subscription_id
  }))

  # Use SSH Key-based Authentication (recommended for security)
  admin_username = "azureuser"
  admin_ssh_key {
    username   = "azureuser"
    public_key = sdm_resource.ssh-gateway.ssh[0].public_key
  }

  # Define the OS image (Ubuntu 20.04 LTS in this example)
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  # Custom VM Tags
  tags = merge(var.tagset, {
    network = "Public"
    class   = "sdminfra"
  })
}

// Grant the StrongDM gateway's managed identity Reader access at subscription level
// This allows the gateway to discover and scan Azure resources (VMs, SQL servers, AKS clusters)
resource "azurerm_role_assignment" "gateway_reader" {
  scope                = data.azurerm_subscription.subscription.id
  role_definition_name = "Reader"
  principal_id         = azurerm_linux_virtual_machine.sdmgw.identity[0].principal_id

}
