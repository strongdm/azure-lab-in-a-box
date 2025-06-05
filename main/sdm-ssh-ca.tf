/*
 * StrongDM SSH Certificate Authority Configuration
 * Retrieves the public key of the StrongDM SSH Certificate Authority
 * This key is used to validate SSH certificates presented by StrongDM clients
 * when connecting to target resources via certificate-based authentication
 */

// Retrieve the public key of the StrongDM SSH Certificate Authority
data "sdm_ssh_ca_pubkey" "ssh_pubkey_query" {
}

data "sdm_rdp_ca_pubkey" "rdp_pubkey_query" {
}