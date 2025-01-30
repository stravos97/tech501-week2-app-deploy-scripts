#!/bin/bash

echo "Updating package list..."
sudo apt-get update -y

echo "Upgrading installed packages..."
sudo apt-get upgrade -y

echo "Installing required dependencies (gnupg and curl)..."
sudo apt-get install -y gnupg curl

echo "Adding MongoDB 7.0.6 GPG key..."
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg

echo "Adding MongoDB repository..."
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] \
https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

echo "Updating package list again..."
sudo apt-get update -y

echo "Installing MongoDB 7.0.6..."
sudo apt-get install -y mongodb-org=7.0.6 mongodb-org-database=7.0.6 \
                         mongodb-org-server=7.0.6 mongodb-mongosh \
                         mongodb-org-mongos=7.0.6 mongodb-org-tools=7.0.6

echo "Configuring MongoDB to bind to all IP addresses..."
sudo sed -i 's/^ *bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf

echo "Enabling MongoDB service..."
sudo systemctl enable mongod
sudo systemctl start mongod

echo "Verifying MongoDB service status..."
sudo systemctl is-enabled mongod

echo "Restarting MongoDB to apply changes..."
sudo systemctl restart mongod

echo "MongoDB installation and configuration complete!"

