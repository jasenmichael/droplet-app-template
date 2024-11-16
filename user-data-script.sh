#!/bin/bash

# # Log files
# COMMAND_LOG_FILE="/var/log/provision-droplet-command-log"
# INIT_LOG_FILE="/var/log/provision-droplet-init-log"
# COMMAND_COUNT=0

# touch "$COMMAND_LOG_FILE" || true
# touch "$INIT_LOG_FILE" || true

# # Function to log the last command
# log_command() {
#   ((COMMAND_COUNT++))
#   local cmd_status=$?

#   # Log the command and status
#   echo "Command ${COMMAND_COUNT}: ${BASH_COMMAND:-"Unknown command"}" | tee -a "$COMMAND_LOG_FILE"
#   echo "----------------------------------------------------" | tee -a "$COMMAND_LOG_FILE"

#   if [ $cmd_status -ne 0 ]; then
#     echo "Command ${COMMAND_COUNT} failed: ${BASH_COMMAND:-"Unknown command"}" | tee -a "$COMMAND_LOG_FILE"
#     echo "failed" >"$INIT_LOG_FILE"
#     exit $cmd_status
#   else
#     echo "Command ${COMMAND_COUNT} succeeded: ${BASH_COMMAND:-"Unknown command"}" | tee -a "$COMMAND_LOG_FILE"
#   fi
# }

# # Trap to run log_command after each command
# trap log_command DEBUG

# Start the provisioning script

# Create the APP_USER user and setup environment
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

# Update and install Ansible
apt-get update -y
apt install ansible -y

# If the script reaches this point, mark success
# echo "succeed" >"$INIT_LOG_FILE"
