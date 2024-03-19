#!/bin/bash
sudo apt-get update -y &&
sudo apt-get upgrade -y \
apt-transport-https \
ca-certificates \
curl \
gnupg \
gnupg-agent \
lsb-release \
wget \
golang-go \
software-properties-common &&
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &&
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add - &&
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list &&
sudo apt-get update -y &&
sudo sudo apt-get install docker-ce docker-ce-cli containerd.io build-essential git trivy -y &&
sudo usermod -aG docker ubuntu
git clone https://github.com/project-copacetic/copacetic
cd copacetic
sudo make
# OPTIONAL: install copa to a pathed folder
sudo mv dist/linux_amd64/release/copa /usr/local/bin/