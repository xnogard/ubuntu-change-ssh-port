#!/bin/bash

# Define new SSH port
NEW_SSH_PORT=22000
SSH_CONFIG="/etc/ssh/sshd_config"

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root. Use: sudo $0"
    exit 1
fi

echo "📌 Backing up SSH configuration..."
cp $SSH_CONFIG ${SSH_CONFIG}.bak

echo "🔧 Updating SSH port to $NEW_SSH_PORT..."
sed -i "s/^#Port 22/Port $NEW_SSH_PORT/" $SSH_CONFIG
sed -i "s/^Port 22/Port $NEW_SSH_PORT/" $SSH_CONFIG

echo "🔒 Disabling root login..."
sed -i "s/^#PermitRootLogin yes/PermitRootLogin no/" $SSH_CONFIG
sed -i "s/^PermitRootLogin yes/PermitRootLogin no/" $SSH_CONFIG

echo "🔄 Restarting SSH service..."
systemctl restart ssh

systemctl daemon-reload
systemctl restart ssh.socket

echo "🛡️ Configuring UFW firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow $NEW_SSH_PORT/tcp

# Remove old SSH port (22) from UFW if it exists
if ufw status | grep -q "22/tcp"; then
    ufw delete allow 22/tcp
fi

echo "✅ Enabling UFW..."
yes | ufw enable

echo "🔄 Reloading UFW rules..."
ufw reload

echo "🔍 Verifying SSH is running on the new port..."
ss -tulnp | grep ssh

echo -e "\n🚀 SSH Security Hardening Complete!"
echo "✔️ SSH Port changed to: $NEW_SSH_PORT"
echo "✔️ Root login disabled"
echo "✔️ UFW enabled (deny all incoming, allow all outgoing)"
echo "✔️ Allowed SSH on port $NEW_SSH_PORT"

echo -e "\n🚨 IMPORTANT: Before logging out, test your new SSH connection:"
echo "👉 ssh -p $NEW_SSH_PORT user@your_server_ip"
