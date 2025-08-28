output "relay_subnet" {
  value = azurerm_subnet.relay.id
}

output "gateway_subnet" {
  value = azurerm_subnet.gateway.id
}

output "vnid" {
  value = azurerm_virtual_network.vn.id
}

output "vnname" {
  value = azurerm_virtual_network.vn.name
}

output "natip" {
  value = azurerm_public_ip.nat.ip_address
}
