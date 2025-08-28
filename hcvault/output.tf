output "ip" {
  value = azurerm_network_interface.sdm-vault-nic.private_ip_address
}

output "target_user" {
  value = var.target_user
}

output "tagset" {
  value = local.thistagset
}