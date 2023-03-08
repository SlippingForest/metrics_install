#!/bin/bash

clear
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

default_user=$(last pts/0 -1 | awk '{print $1; exit}')
default_user_directory=$(eval echo ~$default_user)

# Define the service name and description
SERVICE_EXPORTER_NAME=metrics-exporter
SERVICE_AGENT_NAME=metrics-agent

APP_EXPORTER_PATH=$default_user_directory/$SERVICE_EXPORTER_NAME
APP_AGENT_PATH=$default_user_directory/$SERVICE_AGENT_NAME

# Check if the service exporter exists
if systemctl list-unit-files --type=service | grep -q "^$SERVICE_EXPORTER_NAME"; then
    echo "Service '$SERVICE_EXPORTER_NAME' exists."

    # Check iptables-persistent installed
    if dpkg -s iptables-persistent >/dev/null 2>&1; then
        # Remove any rules that contain port 48620
        iptables -S | grep "dport 48620" | sed "s/-A/-D/" | while read rule; do
            echo "Removing rule: $rule"
            iptables $rule
            netfilter-persistent save
        done
    else
        echo "iptables-persistent not installed"
    fi

    # Stop the service if it is currently running
    sudo systemctl stop $SERVICE_EXPORTER_NAME

    # Disable the service so that it doesn't start automatically at boot time
    sudo systemctl disable $SERVICE_EXPORTER_NAME

    # Remove the service configuration files
    sudo rm /etc/systemd/system/$SERVICE_EXPORTER_NAME.*

    # Reload the systemd configuration
    sudo systemctl daemon-reload

    # Delete the app directory
    if [ -d "$APP_EXPORTER_PATH" ]; then
        echo "Removing app directory: $APP_EXPORTER_PATH"
        rm -rf $APP_EXPORTER_PATH
    fi

    echo "Service '$SERVICE_EXPORTER_NAME' has been removed."
else
    echo "Service '$SERVICE_EXPORTER_NAME' does not exist."
fi


# Check if the service agent exists
if systemctl list-unit-files --type=service | grep -q "^$SERVICE_AGENT_NAME"; then
    echo "Service '$SERVICE_AGENT_NAME' exists."

    # Stop the service if it is currently running
    sudo systemctl stop $SERVICE_AGENT_NAME

    # Disable the service so that it doesn't start automatically at boot time
    sudo systemctl disable $SERVICE_AGENT_NAME

    # Remove the service configuration files
    sudo rm /etc/systemd/system/$SERVICE_AGENT_NAME.*

    # Reload the systemd configuration
    sudo systemctl daemon-reload

    # Delete the app directory
    if [ -d "$APP_AGENT_PATH" ]; then
        echo "Removing app directory: $APP_AGENT_PATH"
        rm -rf $APP_AGENT_PATH
    fi

    echo "Service '$SERVICE_AGENT_NAME' has been removed."
else
    echo "Service '$SERVICE_AGENT_NAME' does not exist."
fi

echo "Done."