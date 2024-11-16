#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
  echo "Not running as root. Switching to root..."
  sudo su
  exit 0
fi

# Create APP_USER user
useradd -m -U -s /bin/bash ${APP_USER}
usermod -aG sudo ${APP_USER}

# Set up SSH for APP_USER user
mkdir -p /home/${APP_USER}/.ssh
echo "${GH_TO_DROPLET_PUBLIC_KEY}" >/home/${APP_USER}/.ssh/authorized_keys
chmod 700 /home/${APP_USER}/.ssh
chmod 600 /home/${APP_USER}/.ssh/authorized_keys
chown -R ${APP_USER}:${APP_USER} /home/${APP_USER}/.ssh

# Grant passwordless sudo access
echo "%sudo ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers
echo "root ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers
echo "${APP_USER} ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers

apt-get update -y
apt install ansible -y

mkdir -p /var/log
echo "succeed" >/var/log/provision-droplet-command.log
