#!/usr/bin/env bash

export SDM_RELAY_TOKEN=${sdm_relay_token}
export TARGET_USER=${target_user}
export SDM_HOME="/home/$TARGET_USER/.sdm"
apt-get update -y | logger -t sdminstall
apt-get upgrade -y | logger -t sdminstall
apt-get install -y unzip jq| logger -t sdminstall
curl -J -O -L https://app.strongdm.com/releases/cli/linux && unzip sdmcli* && rm sdmcli*
systemctl disable ufw.service
systemctl stop ufw.service
# Install SDM
%{ if sdm_domain != "" }
sudo ./sdm install --relay --token=$SDM_RELAY_TOKEN --user=$TARGET_USER --domain=${sdm_domain}| logger -t sdminstall
%{ endif }
%{ if sdm_domain == "" }
sudo ./sdm install --relay --token=$SDM_RELAY_TOKEN --user=$TARGET_USER| logger -t sdminstall
%{ endif }
%{ if vault_ip != "" }
JWT=$(curl -s 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F' -H Metadata:true | jq -r '.access_token')
RG=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2017-08-01" | jq -r .compute.resourceGroupName)
SUBSCRIPTION_ID=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2017-08-01" | jq -r '.compute | .subscriptionId')
vm_name=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2017-08-01" | jq -r '.compute | .name')
VAULT_TOKEN=$(curl     --request POST     --data '{"role": "strongdm", "jwt": "'$JWT'", "subscription_id":"'$SUBSCRIPTION_ID'", "resource_group_name":"'$RG'", "vm_name":"'$vm_name'"}'     http://10.0.2.6:8200/v1/auth/azure/login | jq -r .auth.client_token)
sudo printf "\nVAULT_TOKEN=$VAULT_TOKEN\n" >> /etc/sysconfig/sdm-proxy
sudo service sdm-proxy restart
%{ endif }