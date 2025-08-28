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
    name           = "sdm-${var.name}-lab-gw"
    listen_address = "${azurerm_public_ip.sdm-gw-ip.ip_address}:5000"
    bind_address   = "0.0.0.0:5000"
    tags = merge(var.tagset, {
      network = "Public"
      class   = "sdminfra"
    })
  }
}

// SSH access resource for the Gateway VM itself (for administrative purposes)
resource "sdm_resource" "ssh-gateway" {
  ssh {
    name     = "${var.name}-sdm-gateway"
    hostname = azurerm_network_interface.sdm-gw-nic.private_ip_address
    username = "azureuser"
    port     = 22
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
  size                  = "Standard_B1s" # Minimal VM size
  network_interface_ids = [azurerm_network_interface.sdm-gw-nic.id]
  user_data = base64encode(templatefile("${path.module}/gw-provision.tpl", {
    sdm_relay_token = sdm_node.gateway.gateway[0].token
    target_user     = "azureuser"
    vault_ip        = ""
    #sdm_domain         = element(split(":", data.env_var.sdm_api.value), 0)
    sdm_domain = data.env_var.sdm_api.value == "" ? "" : coalesce(join(".", slice(split(".", element(split(":", data.env_var.sdm_api.value), 0)), 1, length(split(".", element(split(":", data.env_var.sdm_api.value), 0))))), "")
    }
    )
  )

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
  # Custom VM Tags
  tags = merge(var.tagset, {
    network = "Public"
    class   = "sdminfra"
  })
}
