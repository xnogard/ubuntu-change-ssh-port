Simple script to harden a new install of Ubuntu, change the default port of SSH and disable root login.

You may want to install **fail2ban**

    sudo apt install fail2ban
    sudo systemctl enable --now fail2ban

Lock down your firewall

    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow 80,443/tcp  # Allow HTTP/HTTPS if running a web server
    sudo ufw enable
