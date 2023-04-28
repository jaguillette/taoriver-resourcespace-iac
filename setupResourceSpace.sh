#! /bin/bash

# Install ansible
apt update -y 
apt install software-properties-common
add-apt-repository --yes --update ppa:ansible/ansible
apt install ansible
apt-cache policy ansible > ~/ansible_version.txt

# pull the playbook from a git repository
git clone 

# run the playbook
