#!/bin/bash

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt install nginx -y

# downloading node js

sudo DEBIAN_FRONTEND=noninteractive bash -c "curl -fsSL https://deb.nodesource.com/setup_20.x | bash -" && \
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs

node -v
npm -v

cd /repo/app/
npm install

npm start # return: your app is ready and listening on port 3000
