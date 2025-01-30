#!/bin/bash

# Prompt the user to confirm if the DB VM is running
read -p "Is the DB VM running? (yes/no): " db_running

# Check the user's response
if [[ "$db_running" != "yes" ]]; then
    echo "Please ensure the DB VM is running before proceeding."
    exit 1
fi

# Prompt the user to enter the VNet IP of the DB VM
read -p "Enter the VNet IP of the DB VM: " vnet_ip

# Navigating into the app folder
cd /repo/app

# Export DB_HOST with the provided VNet IP
export DB_HOST="mongodb://$vnet_ip:27017/posts"

# Starting the app with PM2
pm2 start app.js

