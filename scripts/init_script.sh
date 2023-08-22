#!/bin/bash

USERNAME="lion"
PASSWORD="1234"
REMOTE_DIRECTORY="/home/$USERNAME/"

# create user
echo "Add user"
useradd -s /bin/bash -d $REMOTE_DIRECTORY -m $USERNAME

# set password
echo "Set password"
echo "$USERNAME:$PASSWORD" | chpasswd

# user auth
echo "Set sudo"
usermod -aG sudo $USERNAME
echo "$USERNAME ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers.d/$USERNAME

# install docker
echo "Update apt and Install docker & docker-compose"
sudo apt-get update
sudo apt install -y docker.io docker-compose

# start docker
echo "Start docker"
sudo service docker start && sudo service docker enable

# docker auth
echo "Add user to 'docker' group"
sudo usermod -aG docker $USERNAME

echo "done"