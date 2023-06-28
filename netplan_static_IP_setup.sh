#!/bin/bash

# Get the current network interface
interface=$(ip route get 8.8.8.8 | awk '{print $5}')

# Get the IP address for the network interface
ip_address=$(ip addr show dev $interface | grep "inet " | awk '{print $2}')

# Get the default gateway
gateway=$(ip route | grep default | awk '{print $3}')

# Create the Netplan YAML configuration
yaml=$(cat <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    $interface:
      dhcp4: no
      addresses: [$ip_address]
      gateway4: $gateway
      nameservers:
        addresses: [8.8.8.8]
EOF
)

# Save the YAML configuration to /etc/netplan/netplan.yaml
echo "$yaml" | sudo tee /etc/netplan/01-network-manager-all.yaml >/dev/null

# Apply the new Netplan configuration
sudo netplan try
