resource "azurerm_network_interface" "sdm-relay-nic" {
  name                = "sdmrelay-nic"
  location            = var.region
  resource_group_name = coalesce(var.rg,one(module.rg[*].rgname))

  ip_configuration {
    name                          = "internal"
    subnet_id                     = coalesce(var.relay_subnet,one(module.network[*].relay_subnet))
    private_ip_address_allocation = "Dynamic"
  }
  tags = merge (var.tagset, {
            network = "Private"
            class   = "sdminfra"
        })

}

resource "sdm_node" "relay" {
    relay {
        name = "sdm-lab-relay"
    }
}

resource "sdm_resource" "ssh-relay" {
    ssh {
        name     = "sdm-relay"
        hostname = azurerm_network_interface.sdm-relay-nic.private_ip_address
        username = "azureuser"
        port     = 22
        tags = merge (var.tagset, {
            network = "Private"
            class   = "sdminfra"
        })
    }

    
}


resource "azurerm_linux_virtual_machine" "sdmrelay" {
  name                  = "sdmr01"
  resource_group_name   = coalesce(var.rg,one(module.rg[*].rgname))
  location              = var.region
  size                  = "Standard_B1s"  # Minimal VM size
  network_interface_ids = [azurerm_network_interface.sdm-relay-nic.id]
  user_data             = base64encode(templatefile("${path.module}/gw-provision.tpl", {
    sdm_relay_token    = sdm_node.relay.relay[0].token
    target_user        = "azureuser"
    }
   )
  )
    # Use SSH Key-based Authentication (recommended for security)
  admin_username        = "azureuser"
  admin_ssh_key {
    username   = "azureuser"
    public_key = sdm_resource.ssh-relay.ssh[0].public_key
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
  tags = merge (var.tagset, {
            network = "Private"
            class   = "sdminfra"
        })

}