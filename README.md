Claro, aquí te presento una versión más estructurada y bonita del markdown:

# Introducción

Esta documentación tiene como objetivo mostrar al usuario cómo configurar y ejecutar PechiNet de una forma sencilla y fácil. Este proyecto está basado en [Headscale](https://github.com/juanfont/headscale/blob/main/docs/running-headscale-container.md) y [Tailscale](https://tailscale.com/). 

Nota: `Interface grafica en desarrollo.`

## Beneficios de usar Pechinet

- **CERO CONFIGURACIÓN DE TU RED LOCAL.**
- **NO ES NECESARIO: ABRIR PUERTOS. TENER UNA IP PUBLICA EN TU DOMILICIO O REDCIDENCIA.**
- **FUNCIONA SI ESTAS CONECTADO A UNA RED MOVIL, WIFI O ETHERNET.**

## Requerimientos

- Tener conocimientos básicos en Linux, Docker, CLI y redes.
- Tener instalado Docker y Docker-Compose.
- Contar con una VPS, no importa el proveedor. ( Si no cuentas con una, puedes usar el plan gratis que ofrece [Oracle Cloud](https://www.oracle.com/cloud/free/) )
- Contar con una máquina local que quieras hacer pública por medio de PechiNet.

## Pasos a seguir

1. Configurar y ejecutar el contenedor Headscale.
2. Instalar y configurar Tailscale en la VPS.
3. Configurar el redireccionamiento del tráfico de entrada de la VPS al servidor local.

## Configuración y ejecución del contenedor de Headscale

### 1. Clonar el repositorio de PechiNet

```bash
git clone https://github.com/NaylaMitcuri/pechinet.git
cd pechinet
```

### 2. Permiso de ejecución del script

```shell
sudo chmod +x script_install_es.sh
```

### 3. Información relevante

Si deseas modificar los puertos por defecto del contenedor, puedes ir a: `docker-compose.yaml`

```yaml
version: "3.7"
services:
  headscale:
    image: headscale/headscale:0.23.0-alpha5
    restart: unless-stopped
    container_name: headscale
    ports:
      # Modifica el puerto a tu preferencia "0.0.0.0[Puerto local][Puerto del contenedor]"
      - "0.0.0.0:8080:8080"
      - "0.0.0.0:8080:9090"
    volumes:
      - ~/headscale/config:/etc/headscale
    command: serve
```

> **Nota**: Utiliza `0.0.0.0:8080:8080` en lugar de `127.0.0.1:8080:8080` si quieres exponer el contenedor externamente.

### 4. Ejecutar el script e ingresar la información solicitada

```bash
sudo ./script_install_es.sh
```

### 5. Verificar que Headscale se está ejecutando

Sigue los registros del contenedor:

```shell
docker logs --follow headscale
```

Verifica los contenedores en ejecución:

```shell
docker ps
```

Verifica que Headscale está disponible:

```shell
curl http://127.0.0.1:9090/metrics
```

### 6. Crear un usuario ([Tailnet](https://tailscale.com/kb/1136/tailnet/))

```shell
docker exec headscale \
headscale users create myfirstuser
```

### 7. Registrar una máquina (inicio de sesión normal)

En una máquina cliente, ejecuta el comando `tailscale` login:

```shell
tailscale up --login-server http://ip_de_servidor:8080 --hostname=name_device
```

Para registrar una máquina cuando se ejecuta `headscale` en un contenedor, toma el comando headscale y pásalo al contenedor:

```shell
docker exec headscale \
headscale --user myfirstuser nodes register --key <TU_CLAVE_DE_MAQUINA>
```

### 8. Registrar máquina utilizando una clave pre-autenticada

Genera una clave utilizando la línea de comandos:

```shell
docker exec headscale \
headscale --user myfirstuser preauthkeys create --reusable --expiration 24h
```

Esto devolverá una clave pre-autenticada que se puede utilizar para conectar un nodo a `headscale` durante el comando `tailscale`:

```shell
tailscale up --login-server <TU_URL_HEADSCALE> --authkey <TU_CLAVE_DE_AUTENTICACION>
```

## Instalar y configurar Tailscale en la VPS.

Puedes instalar [Tailcale](https://tailscale.com/) desde la pagina oficional.

En linux puedes instalarlo con:

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```
Puedes verificar que este instalado con:

```bash
tailscale --version
```
Una vez instalado deberas ejecutar el siguiente comando:

