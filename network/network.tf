/*
 * Network module - Creates the foundation network resources for the StrongDM lab
 * This file creates:
 * - A virtual network
 * - Public subnet for gateway components
 * - Private subnet for relay components
 * - NAT Gateway with public IP for private subnet outbound connectivity
 */

// Virtual Network for the StrongDM lab environment
resource "azurerm_virtual_network" "vn" {
  name                = "${var.name}-vn"
  location            = var.region
  resource_group_name = var.rg
  address_space       = ["10.0.0.0/16"]

  tags = local.thistagset
}

// Public subnet used for StrongDM gateway components
resource "azurerm_subnet" "gateway" {
  resource_group_name  = var.rg
  address_prefixes     = ["10.0.1.0/24"]
  name                 = "${var.name}-gateway"
  virtual_network_name = azurerm_virtual_network.vn.name

}

// Private subnet used for StrongDM relay and target components
resource "azurerm_subnet" "relay" {
  resource_group_name  = var.rg
  address_prefixes     = ["10.0.2.0/24"]
  name                 = "${var.name}-relay"
  virtual_network_name = azurerm_virtual_network.vn.name
}

// Public IP for NAT Gateway to allow outbound connectivity from private subnet
resource "azurerm_public_ip" "nat" {
  name                = "${var.name}-Nat-PIP"
  location            = var.region
  resource_group_name = var.rg
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge (local.thistagset, {
    network = "Public"
  })
}

// NAT Gateway to provide outbound internet connectivity for resources in private subnet
resource "azurerm_nat_gateway" "natgw" {
  name                = "${var.name}-NatGateway"
  location            = var.region
  resource_group_name = var.rg
  sku_name            = "Standard"

  tags = merge (local.thistagset, {
    network = "Public"
  })
}

// Association between NAT Gateway and its Public IP
resource "azurerm_nat_gateway_public_ip_association" "natassoc" {
  nat_gateway_id       = azurerm_nat_gateway.natgw.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "gwnga" {
  subnet_id      = azurerm_subnet.gateway.id
  nat_gateway_id = azurerm_nat_gateway.natgw.id
}

resource "azurerm_subnet_nat_gateway_association" "rnga" {
  subnet_id      = azurerm_subnet.relay.id
  nat_gateway_id = azurerm_nat_gateway.natgw.id
}

resource "azurerm_network_security_group" "relay" {
  name                = "${var.name}-relay"
  location            = var.region
  resource_group_name = var.rg
  security_rule {
    name                       = "Allow-Outbound-${var.name}"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "Internet"
  }

  tags = merge (local.thistagset, {
    network = "Private"
  })
}

resource "azurerm_network_security_group" "gateway" {
  name                = "${var.name}-gateway"
  location            = var.region
  resource_group_name = var.rg
  security_rule {
    name                       = "Allow-Accessing-gateways"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "5000"
    source_port_range          = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "VirtualNetwork"
  }
#SSH Access for troubleshooting
  security_rule {
    name                       = "Allow-Accessing-SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "22"
    source_port_range          = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name                       = "Allow-Outbound-DMZ"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "Internet"
  }

  tags = merge (local.thistagset, {
    network = "Public"
  })
}

resource "azurerm_subnet_network_security_group_association" "gwsg" {
  subnet_id                 = azurerm_subnet.gateway.id
  network_security_group_id = azurerm_network_security_group.gateway.id
}

resource "azurerm_subnet_network_security_group_association" "rsg" {
  subnet_id                 = azurerm_subnet.relay.id
  network_security_group_id = azurerm_network_security_group.relay.id
}
