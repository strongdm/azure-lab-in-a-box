/*
 * StrongDM Relay Configuration
 * Sets up a relay server in the private subnet that enables secure access to resources
 * Uses a system-assigned managed identity for authentication to Azure services
 * Automatically registers with the StrongDM control plane during provisioning
 */

// Network interface for the StrongDM relay in the private subnet
resource "azurerm_network_interface" "sdm-relay-nic" {
  name                = "${var.name}-sdmrelay-nic"
  location            = var.region
  resource_group_name = coalesce(var.rg, one(module.rg[*].rgname))

  ip_configuration {
    name                          = "internal"
    subnet_id                     = coalesce(var.relay_subnet, one(module.network[*].relay_subnet))
    private_ip_address_allocation = "Dynamic"
  }
  tags = merge(var.tagset, {
    network = "Private"
    class   = "sdminfra"
  })
}

// StrongDM Relay node definition that registers with the StrongDM control plane
resource "sdm_node" "relay" {
  relay {
    name = var.strongdm_naming.relay_prefix
    tags = { "eng__${var.name}AD" = "true" }
  }
}

// SSH access resource for the Relay VM itself (for administrative purposes)
resource "sdm_resource" "ssh-relay" {
  ssh {
    name     = "${var.name}-sdm-relay"
    hostname = azurerm_network_interface.sdm-relay-nic.private_ip_address
    username = var.admin_usernames.linux_admin
    port     = var.service_ports.ssh
    tags = merge(var.tagset, {
      network             = "Private"
      class               = "sdminfra"
      "eng__${var.name}AD" = "true"

    })
  }
}

// Linux VM that will run the StrongDM relay service
resource "azurerm_linux_virtual_machine" "sdmrelay" {
  name                  = "${var.name}-sdmr01"
  resource_group_name   = coalesce(var.rg, one(module.rg[*].rgname))
  location              = var.region
  size                  = var.vm_sizes.relay
  network_interface_ids = [azurerm_network_interface.sdm-relay-nic.id]

  // Custom data script that installs and configures the StrongDM relay
  // Also configures HashiCorp Vault integration if enabled
  user_data = base64encode(templatefile("${path.module}/gw-provision.tpl", {
    sdm_relay_token       = sdm_node.relay.relay[0].token
    target_user           = "azureuser"
    vault_ip              = var.create_hcvault == false ? "" : one(module.hcvault[*].ip)
    sdm_domain            = data.env_var.sdm_api.value == "" ? "" : coalesce(join(".", slice(split(".", element(split(":", data.env_var.sdm_api.value), 0)), 1, length(split(".", element(split(":", data.env_var.sdm_api.value), 0))))), "")
    azure_tenant_id       = data.azurerm_client_config.current.tenant_id
    azure_subscription_id = data.azurerm_subscription.subscription.subscription_id
  }))

  // Use SSH Key-based Authentication (recommended for security)
  admin_username = "azureuser"
  admin_ssh_key {
    username   = "azureuser"
    public_key = sdm_resource.ssh-relay.ssh[0].public_key
  }

  // Define the OS image (Ubuntu 20.04 LTS in this example)
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

  // Custom VM Tags
  tags = merge(var.tagset, {
    network = "Private"
    class   = "sdminfra"
  })
}

// Grant the StrongDM relay's managed identity Reader access at subscription level
// This allows the relay to discover and scan Azure resources (VMs, SQL servers, AKS clusters)
resource "azurerm_role_assignment" "relay_reader" {
  scope                = data.azurerm_subscription.subscription.id
  role_definition_name = "Reader"
  principal_id         = azurerm_linux_virtual_machine.sdmrelay.identity[0].principal_id
}
