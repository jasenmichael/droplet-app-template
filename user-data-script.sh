#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
  echo "Not running as root. Switching to root..."
  exec sudo -i
fi

trap 'on_error' ERR
on_error() {
  echo "Error: Command failed with exit code $?. Exiting script..."
  echo "fail" >/home/${APP_USER}/log/provision-droplet-init.log
  exit 1
}

# Create APP_USER user
useradd -m -U -s /bin/bash ${APP_USER} || true
usermod -aG sudo ${APP_USER}

mkdir -p /home/${APP_USER}/log/ || true
touch /home/${APP_USER}/log/provision-droplet-init.log || true

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

echo "succeed" >/home/${APP_USER}/log/provision-droplet-init.log
