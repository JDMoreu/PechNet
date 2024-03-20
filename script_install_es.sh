#!/bin/bash

# Paso 1: Instalar Docker y Docker Compose
echo "Instalando Docker y Docker Compose..."
sudo apt update
sudo apt install -y docker.io docker-compose

# Verificar si la instalación fue exitosa
docker --version
docker-compose --version

# Paso 2: Copiar el directorio 'headscale' a la carpeta de inicio del usuario actual
echo "Copiando el directorio 'headscale' al directorio personal..."
cp -r ./headscale ~/

# Paso 3: Solicitar entrada del usuario y modificar el archivo de configuración
echo "Por favor, escribe tu hostname (por ejemplo, 149.128.135.54:8080):"
read -p "your-host-name: " hostname_input

# Modificar el archivo de configuración con el hostname ingresado
echo "Modificando el archivo de configuración..."
sed -i "s|http://your-host-name:8080|http://$hostname_input|g" ~/headscale/config/config.yml

# Paso 4: Solicitar entrada del usuario para el base domain
echo "Por favor, escribe el base domain (por ejemplo, myuser.headscale.com):"
read -p "hostname.user.base_domain: " base_domain_input

# Modificar el archivo de configuración con el base domain ingresado
echo "Modificando el archivo de configuración..."
sed -i "s|user.headscale.com|$base_domain_input|g" ~/headscale/config/config.yml

# Paso 5: Ejecutar docker-compose up -d
echo "Ejecutando docker-compose up -d..."
docker-compose up -d

echo "Proceso completado."
