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
software-properties-common &&
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &&
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add - &&
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list &&
git clone https://github.com/udhos/update-golang &&
sudo update-golang/update-golang.sh &&
source /etc/profile.d/golang_path.sh &&
sudo apt-get update -y &&
sudo sudo apt-get install docker-ce docker-ce-cli containerd.io build-essential git trivy -y &&
sudo usermod -aG docker ubuntu
git clone https://github.com/project-copacetic/copacetic
cd copacetic
make
# OPTIONAL: install copa to a pathed folder
sudo mv dist/linux_amd64/release/copa /usr/local/bin/
export BUILDKIT_VERSION=v0.13.1
export BUILDKIT_PORT=8888
sudo docker run \
    --detach \
    --rm \
    --privileged \
    -p 127.0.0.1:$BUILDKIT_PORT:$BUILDKIT_PORT/tcp \
    --name buildkitd \
    --entrypoint buildkitd \
    "moby/buildkit:$BUILDKIT_VERSION" \
    --addr tcp://0.0.0.0:$BUILDKIT_PORT