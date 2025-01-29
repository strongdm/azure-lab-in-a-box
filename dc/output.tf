
output "dc_ip" {
    value = azurerm_network_interface.sdm-dc-nic.private_ip_address
}

output "dc_username" {
    value = var.target_user
}

output "dc_password" {
    value = local.admin_password
}

output "domain_admin" {
    value = var.target_user
}

output "domain_password" {
    value = "${local.admin_password}!"
}

output "thistagset" {
    value = local.thistagset
} 

output "netbios_domain" {
    value = var.name
}

output "domain" {
    value = "${var.name}.local"
}