#!/bin/bash

set -e
exec > /tmp/debug-my-script.txt 2>&1

useradd -m appadmin
mkhomedir_helper appadmin
passwd -d appadmin
sleep 20
sudo apt update
sudo apt -y install curl
su - appadmin -c "touch ~/.bash_profile"
su - appadmin -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash"
sleep 5
sudo apt -y install npm
su - appadmin -c "git clone https://github.com/commitgcp/okta-nodejs-postgres-weight-tracker-example.git ~/app/"
su - appadmin -c "cd ~/app/ && npm install"
su - appadmin -c ". ~/.nvm/nvm.sh && nvm install 12 && sleep 10 && cd ~/app && npm run dev"
#su - appadmin -c "npm run initdb"