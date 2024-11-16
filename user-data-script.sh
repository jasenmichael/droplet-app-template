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
touch /home/${APP_USER}/log/provision-droplet-init.log || true

# Check if the current user is root, if not, switch to root and preserve the script execution
if [ "$(id -u)" -ne 0 ]; then
  echo "Not running as root. Switching to root..."
  sudo su - root -c "/bin/bash --login" # Switch to root and preserve login shell
  exit 0
fi

# Main script logic
# Create APP_USER user (ensure it does not fail if user exists)
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

# #!/bin/bash

# mkdir -p /home/${APP_USER}/log
# touch /home/${APP_USER}/log/provision-droplet-init.log || true

# if [ "$(id -u)" -ne 0 ]; then
#   echo "Not running as root. Switching to root..."
#   exec sudo -i
# fi

# trap 'on_error' ERR
# on_error() {
#   echo "Error: Command failed with exit code $?. Exiting script..."
#   echo "fail" >/home/${APP_USER}/log/provision-droplet-init.log
#   exit 1
# }

# # Create APP_USER user
# useradd -m -U -s /bin/bash ${APP_USER} || true
# usermod -aG sudo ${APP_USER}

# # Set up SSH for APP_USER user
# mkdir -p /home/${APP_USER}/.ssh
# echo "${GH_TO_DROPLET_PUBLIC_KEY}" >/home/${APP_USER}/.ssh/authorized_keys
# chmod 700 /home/${APP_USER}/.ssh
# chmod 600 /home/${APP_USER}/.ssh/authorized_keys
# chown -R ${APP_USER}:${APP_USER} /home/${APP_USER}/.ssh

# # Grant passwordless sudo access
# echo "%sudo ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers
# echo "root ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers
# echo "${APP_USER} ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers

# apt-get update -y
# apt install ansible -y

# echo "succeed" >/home/${APP_USER}/log/provision-droplet-init.log
