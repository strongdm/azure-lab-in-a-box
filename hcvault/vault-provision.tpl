#!/usr/bin/env bash
export VAULT_ADDR=http://${ip}:8200/
export TARGET_USER=${target_user}
apt-get update -y | logger -t sdminstall
apt-get upgrade -y | logger -t sdminstall
apt-get install -y unzip jq| logger -t sdminstall
systemctl disable ufw.service
systemctl stop ufw.service
echo "Copying SSHCA ${sshca} to /etc/ssh/sdm_ca.pub" | logger -t sdminstall
echo "${sshca}" | sudo tee -a /etc/ssh/sdm_ca.pub
echo "Setting SSH CA permissions" | logger -t sdminstall
chmod 600 /etc/ssh/sdm_ca.pub
echo "Enabling $TARGET_USER to login using SSH CA" | logger -t sdminstall
mkdir /etc/ssh/sdm_users
sudo echo "strongdm" > /etc/ssh/sdm_users/$TARGET_USER
echo "Reconfiguring SSHD" | logger -t sdminstall
echo "TrustedUserCAKeys /etc/ssh/sdm_ca.pub" | sudo tee -a /etc/ssh/sshd_config.d/100-strongdm.conf
echo "AuthorizedPrincipalsFile /etc/ssh/sdm_users/%u" | sudo tee -a /etc/ssh/sshd_config.d/100-strongdm.conf
echo "Restarting SSHD" | logger -t sdminstall
systemctl restart ssh
echo "StrongDM target configuration done" | logger -t sdminstall
sudo systemctl restart ssh

echo "Downloading HashiCorp Vault" | logger -t sdminstall
curl -O https://releases.hashicorp.com/vault/${vault_version}/vault_${vault_version}_linux_amd64.zip

echo "Installing HashiCorp Vault" | logger -t sdminstall

unzip vault_${vault_version}_linux_amd64.zip

sudo cp vault /usr/bin/vault

sudo chmod +x /usr/bin/vault

sudo tee /lib/systemd/system/vault.service <<EOF
[Unit]
Description="HashiCorp Vault"
Documentation="https://developer.hashicorp.com/vault/docs"
ConditionFileNotEmpty="/etc/vault.d/vault.hcl"

[Service]
User=${target_user}
Group=${target_user}
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/bin/vault server -config=/etc/vault.d/
ExecReload=/bin/kill --signal HUP
KillMode=process
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
EOF

sudo mkdir /etc/vault.d/
sudo mkdir /opt/vault
sudo chown ${target_user}:${target_user} /opt/vault
tee /etc/vault.d/akv-seal.hcl <<EOF
seal "azurekeyvault" {
  vault_name     = "${akvname}"
  key_name       = "${akvkey}"
}
EOF

tee /etc/vault.d/storage.hcl <<EOF
storage "file" {
  path = "/opt/vault"
}
EOF

tee /etc/vault.d/vault.hcl <<EOF
ui            = true
EOF

tee /etc/vault.d/listener.hcl <<EOF
listener "tcp" {
  address = <<EOM
{{- GetInterfaceIP "eth0" -}}:8200
EOM
  tls_disable = true
}
EOF

sudo chown -R ${target_user}:${target_user} /etc/vault.d
sudo systemctl daemon-reload

sudo service vault start
sudo systemctl enable vault.service
echo "Waiting for Vault to start"
sleep 30
export VAULT_ADDR=http://${ip}:8200/

vault operator init \
    -recovery-shares=3 \
    -recovery-threshold=2 \
    -format=json | tee ~/vault-init.json
    
echo "Waiting for Vault to generate keys"
sleep 30

export VAULT_TOKEN=$(cat ~/vault-init.json | jq -r .root_token)

vault auth enable azure
vault write auth/azure/config tenant_id=${tenant} resource=https://management.azure.com/

vault secrets enable kv

tee kvaccess.hcl <<EOF
path "kv/*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}
EOF
cat kvaccess.hcl | vault policy write kvaccess -

vault write auth/azure/role/strongdm \
    policies="kvaccess,default" \
    bound_subscription_ids=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2017-08-01" | jq -r '.compute | .subscriptionId') \
    bound_resource_groups=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2017-08-01" | jq -r '.compute | .resourceGroupName')