output "ip" {
    value = azurerm_network_interface.sdm-windows-nic.private_ip_address
}

output "username" {
    value = var.target_user
}

output "password" {
    value = local.admin_password
}

output "thistagset" {
    value = local.thistagset
} 