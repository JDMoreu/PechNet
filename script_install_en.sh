#!/bin/bash

# Step 1: Install Docker and Docker Compose
echo "Installing Docker and Docker Compose..."
sudo apt update
sudo apt install -y docker.io docker-compose

# Checking if the installation was successful
docker --version
docker-compose --version

# Step 2: Copy the 'headscale' directory to the user's home directory
echo "Copying the 'headscale' directory to the home directory..."
cp -r ./headscale ~/

# Step 3: Prompt user input and modify the configuration file
echo "Please enter your hostname (e.g., 149.128.135.54:8080):"
read -p "your-host-name: " hostname_input

# Modifying the configuration file with the entered hostname
echo "Modifying the configuration file..."
sed -i "s|http://your-host-name:8080|http://$hostname_input|g" ~/headscale/config/config.yml

# Step 4: Prompt user input for the base domain
echo "Please enter the base domain (e.g., myuser.headscale.com):"
read -p "hostname.user.base_domain: " base_domain_input

# Modifying the configuration file with the entered base domain
echo "Modifying the configuration file..."
sed -i "s|user.headscale.com|$base_domain_input|g" ~/headscale/config/config.yml

# Step 5: Running docker-compose up -d
echo "Running docker-compose up -d..."
docker-compose up -d

echo "Process completed."
