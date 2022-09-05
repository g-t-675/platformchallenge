#!/bin/bash
# This script setups and runs the dockerized platform challenge on Ubuntu 18.04 (that's what I use)
set -eu


install_docker(){
    # Install Docker
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get -qqy update
    DEBIAN_FRONTEND=noninteractive sudo -E apt-get -qqy -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade 
    sudo apt-get -yy install apt-transport-https ca-certificates curl software-properties-common wget pwgen
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update && sudo apt-get -y install docker-ce

    # Allow current user to run Docker commands
    sudo usermod -aG docker $USER
}

install_docker_compose(){
     # Install Docker Compose
    sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

if ! docker --version; then
	echo "WARNING: Docker not found - installing..."
	install_docker
fi

if ! docker-compose --version; then
	echo "WARNING: Docker Compose not found - installing..."
	install_docker_compose
fi

# Attempt to run a container if not in a container
if [ ! -f /.dockerenv  ]; then
	if ! sudo docker run --rm hello-world; then
		echo "ERROR: Could not get docker to run the hello world container"
		exit 2
	fi
fi

if ! http --version; then 
    echo "WARNING: HTTPie not found - installing..."
    sudo apt-get install httpie
fi

if ! grep 'platform' /etc/hosts; then 
    sudo -- sh -c "echo  \ \ >> /etc/hosts"
    sudo -- sh -c "echo 127.0.0.1  platform >> /etc/hosts"
fi


sudo docker-compose up -d 
echo "Starting service - to stop/restart please run [sudo] docker-compose down/restart!"
sudo docker ps 