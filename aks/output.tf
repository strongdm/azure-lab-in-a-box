output "fqdn" {
    value = azurerm_kubernetes_cluster.k8s.fqdn
}

output "thistagset" {
    value = local.thistagset
}

output "name" {
    value = azurerm_kubernetes_cluster.k8s.name
}