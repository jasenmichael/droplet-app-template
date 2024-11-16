#!/bin/bash

# Function to handle errors
on_error() {
  echo "Error: Command failed with exit code $?. Exiting script..."
  echo "fail" >/home/${APP_USER}/log/provision-droplet-init.log
  exit 1
}

# Set up the error trap
trap 'on_error' ERR

# Create a log directory if not exists
mkdir -p /home/${APP_USER}/log
rm -f /home/${APP_USER}/log/provision-droplet-init.log || true
touch /home/${APP_USER}/log/provision-droplet-init.log || true

# Create APP_USER user if user does not exists
id -u "${APP_USER}" &>/dev/null || useradd -m -U -s /bin/bash "${APP_USER}"
usermod -aG sudo "${APP_USER}"

# Set up SSH for APP_USER user
mkdir -p /home/${APP_USER}/.ssh
echo "${GH_TO_DROPLET_PUBLIC_KEY}" >/home/${APP_USER}/.ssh/authorized_keys
chmod 700 /home/${APP_USER}/.ssh
chmod 600 /home/${APP_USER}/.ssh/authorized_keys
chown -R ${APP_USER}:${APP_USER} /home/${APP_USER}/.ssh

# Grant passwordless sudo access
{
  echo "%sudo ALL=(ALL) NOPASSWD:ALL"
  echo "root ALL=(ALL) NOPASSWD:ALL"
  echo "${APP_USER} ALL=(ALL) NOPASSWD:ALL"
} >>/etc/sudoers

# Install necessary packages
apt-get update -y
apt install ansible -y

# Log success
echo "succeed" >/home/${APP_USER}/log/provision-droplet-init.log
