#!/bin/bash

clear
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

read -p "source link: " installer_link
while ! [[ $installer_link == *"dl=0"* ]]; do
    clear
    echo "[ERROR] Wrong link"
    echo "[EXAMPLE] https://www.dropbox.com/s/.../...?dl=0"
    read -p "paste DropBox link [?dl=0]: " installer_link
done
installer_link=${installer_link%?}1

default_user=$(last pts/0 -1 | awk '{print $1; exit}')
default_user_directory=$(eval echo ~$default_user)

# Define the service name and description
SERVICE_NAME=metrics-agent
SERVICE_DESC="Protect MT&MB agent"

# Check if the directory exists
APP_PATH=$default_user_directory/$SERVICE_NAME
if [ ! -d "$APP_PATH" ]; then
    echo "Creating app directory: $APP_PATH"
    mkdir -p $APP_PATH
else
    echo "Using existing app directory: $APP_PATH"
    sudo systemctl stop $SERVICE_NAME
fi

# Define the path to the Go executable
GO_EXEC=$APP_PATH/$SERVICE_NAME

wget -O $GO_EXEC $installer_link
chmod +x $GO_EXEC

# Create the service file
sudo tee /etc/systemd/system/$SERVICE_NAME.service > /dev/null <<EOF
[Unit]
Description=$SERVICE_DESC
After=network.target

[Service]
User=$default_user
ExecStart=$GO_EXEC
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to load the new service file
sudo systemctl daemon-reload

# Start the service
sudo systemctl start $SERVICE_NAME

# Enable the service to start automatically at boot time
sudo systemctl enable $SERVICE_NAME

# Print status information about the service
sudo systemctl status $SERVICE_NAME