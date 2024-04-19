# Configuración VPS:

### *Contenedor de Headscale y cliente tailscale VPS*

### 1. Clonar el repositorio de PechiNet

```bash
git clone https://github.com/NaylaMitcuri/pechinet.git
cd pechinet
```

### 2. Permiso de ejecución del script

```shell
sudo chmod +x install.sh
```

### Información relevante. ( Si no deseas modificar los puertos omite este paso )

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

### 3. Ejecutar el script e ingresar la información solicitada

```bash
sudo ./install.sh
```

### 4. Verificar que Headscale se está ejecutando

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

### 5. Crear un usuario ([Tailnet](https://tailscale.com/kb/1136/tailnet/))

```shell
docker exec headscale \
headscale users create myfirstuser
```
## Instalar tailscale en la VPS

Puedes instalar [Tailcale](https://tailscale.com/) desde la pagina oficional, en linux con el siguiente comando:

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```
Puedes verificar que este instalado con:

```bash
tailscale --version
```

### Conectar la VPS con `tailscale` a el servicio de `headscale` que corre en la misma VPS.

Para conectarnos al servicio de `headscale` puedes elegir entre el comando A o B:

- **A. Registrar una máquina (inicio de sesión normal)**

En una máquina cliente, ejecuta el comando `tailscale` login:

```shell
tailscale up --login-server http://ip_de_servidor:8080 --hostname=name_device
```

Para registrar una máquina cuando se ejecuta `headscale` en un contenedor, toma el comando headscale y pásalo al contenedor:

```shell
docker exec headscale \
headscale --user myfirstuser nodes register --key <TU_CLAVE_DE_MAQUINA>
```

- **B. Registrar máquina utilizando una clave pre-autenticada**

Genera una clave utilizando la línea de comandos:

```shell
docker exec headscale \
headscale --user myfirstuser preauthkeys create --reusable --expiration 24h
```

Esto devolverá una clave pre-autenticada que se puede utilizar para conectar un nodo a `headscale` durante el comando `tailscale`:

```shell
tailscale up --login-server <TU_URL_HEADSCALE> --authkey <TU_CLAVE_DE_AUTENTICACION>
```
Puedes verificar que estas conectado a la red de `headscale` con:

```shell
# Ejecutar en la VPS
tailscale status
```

## Configurar [Servidor Local](/config_local.md)
