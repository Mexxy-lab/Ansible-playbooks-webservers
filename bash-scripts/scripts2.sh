# 1) Write a script to automate a task, such as:- Deploying a simple web application to a remote server.
📁 Folder Structure

deploy/
├── deploy.sh
└── site/
    ├── index.html
    └── style.css

chmod +x deploy.sh
./deploy.sh

#!/bin/bash

# Configuration
REMOTE_USER="ubuntu"
REMOTE_HOST="your.server.com"
REMOTE_DIR="/var/www/html"
LOCAL_DIR="./site"

# Deploy
echo "Starting deployment..."

# 1. Copy site files to the remote server
scp -r $LOCAL_DIR/* ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}

# 2. Restart the web server (Apache in this case)
ssh ${REMOTE_USER}@${REMOTE_HOST} "sudo systemctl restart apache2"

echo "Deployment complete."


# 2) Write a script to automate a task, such as:- Creating user accounts and setting permissions.

# Using bash create_users.sh

#!/bin/bash

# List of users to create
USERS=("alice" "bob" "charlie")
GROUP="devteam"
DEFAULT_SHELL="/bin/bash"
HOME_BASE="/home"

# Create group if not exists
if ! getent group $GROUP > /dev/null; then
  echo "Creating group: $GROUP"
  sudo groupadd $GROUP
fi

# Create users and set permissions
for USER in "${USERS[@]}"; do
  if id "$USER" &>/dev/null; then
    echo "User $USER already exists. Skipping."
  else
    echo "Creating user: $USER"
    sudo useradd -m -d "$HOME_BASE/$USER" -s "$DEFAULT_SHELL" -g $GROUP "$USER"
    echo "Setting password for $USER"
    echo "$USER:Password123!" | sudo chpasswd

    echo "Setting permissions for $USER"
    sudo chmod 750 "$HOME_BASE/$USER"
    sudo chown "$USER:$GROUP" "$HOME_BASE/$USER"
  fi
done

echo "✅ All users created and configured."

