# Introdución

Esta documentación tiene como objetivo mostrar al usuario cómo configurar y ejecutar PechiNet de una forma sencilla y fácil.

Este proyecto esta basado en [healscale](https://github.com/juanfont/headscale/blob/main/docs/running-headscale-container.md) y [tailscale.](https://tailscale.com/)

## Requerimientos

- Tener conocimientos básicos en Linux, Docker, CLI y redes.
- Tener instalado Docker y Docker-Compose.
- Contar con una VPS (si no cuentas con una, puedes usar el plan gratis que ofrece Oracle Cloud).
- Contar con una máquina local que quieras hacer pública por medio de PechiNet.

## Configuración y ejecución del contenedor de headscale

1. **Clonar el repositorio de PechiNet:**

  ```bash
  git clone https://github.com/NaylaMitcuri/pechinet.git
  cd pechinet

2. **Permiso de ejecuión del Script**


```shell
sudo chmod +x script_install_es-sh

```

3. **Información relevante** si deseas modificar los puertos por defecto del contenedor, puedes ir a:


Ejemplo `docker-compose.yaml`

```yaml
version: "3.7"

services:
  headscale:
    image: headscale/headscale:0.23.0-alpha5
    restart: unless-stopped
    container_name: headscale
    ports:
       #Modifica el puerto a tu preferencia "0.0.0.0[Puerto local][Puerto de Docker]"
      - "0.0.0.0:8080:8080"
      - "0.0.0.0:8080:9090"

    volumes:
      # por favor, cambia [config_path] por la ruta completa del directorio de configuración recién creado
      - [config_path]:/etc/headscale
    command: serve

```
Nota: utiliza `0.0.0.0:8080:8080` en lugar de `127.0.0.1:8080:8080` si quieres exponer el contenedor externamente.

4.**Ejecuta el Script para montar el contenedor e ingresa la información solicitada**

```bash
sudo ./script_install_es.sh
```

5. **Verifica que `headscale` se está ejecutando:**

Sigue los registros del contenedor:

```shell
docker logs --follow headscale
```

Verifica los contenedores en ejecución:

```shell
docker ps
```

Verifica que `headscale` está disponible:

```shell
curl http://localhost:9090/metrics
```

6. **Crea un usuario ([tailnet](https://tailscale.com/kb/1136/tailnet/)):**

```shell
docker exec headscale \
  headscale users create myfirstuser
```

7. **Registrar una máquina (inicio de sesión normal)**

En una máquina cliente, ejecuta el comando `tailscale` login:

```shell
tailscale up --login-server http://ip_de_servidor:8080 --hostname=name_device
```

Para registrar una máquina cuando se ejecuta `headscale` en un contenedor, toma el comando headscale y pásalo al contenedor:

```shell
docker exec headscale \
  headscale --user myfirstuser nodes register --key <YOU_+MACHINE_KEY>
```

8. **Registrar máquina utilizando una clave pre-autenticada**

Genera una clave utilizando la línea de comandos:

```shell
docker exec headscale \
  headscale --user myfirstuser preauthkeys create --reusable --expiration 24h
```

Esto devolverá una clave pre-autenticada que se puede utilizar para conectar un nodo a `headscale` durante el comando `tailscale`:

```shell
tailscale up --login-server <YOUR_HEADSCALE_URL> --authkey <YOUR_AUTH_KEY>
```
