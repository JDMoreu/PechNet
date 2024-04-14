# Ejecutar headscale en un contenedor

!!! advertencia "Documentación comunitaria"

    Esta página no está mantenida activamente por los autores de headscale.
    _No_ está verificada por los desarrolladores de `headscale`.

    **Podría estar desactualizada y podrían faltar pasos necesarios**.

## Objetivo

Esta documentación tiene el objetivo de mostrar a un usuario cómo configurar y ejecutar `headscale` en un contenedor.
Se utiliza [Docker](https://www.docker.com) como implementación de contenedor de referencia, pero no hay razón por la que no debería
funcionar con alternativas como [Podman](https://podman.io). La imagen de Docker se puede encontrar en Docker Hub [aquí](https://hub.docker.com/r/headscale/headscale).

## Configurar y ejecutar `headscale`

1. Prepara un directorio en el nodo host de Docker en el directorio de tu elección, utilizado para almacenar la configuración de `headscale` y la base de datos [SQLite](https://www.sqlite.org/):

```shell
mkdir -p ./headscale/config
cd ./headscale
```

2. Crea una base de datos SQLite vacía en el directorio headscale:

```shell
touch ./config/db.sqlite
```

3. **(Muy recomendado)** Descarga una copia del [archivo de configuración de ejemplo](https://github.com/juanfont/headscale/blob/main/config-example.yaml) del repositorio headscale.

Utilizando wget:

```shell
wget -O ./config/config.yaml https://raw.githubusercontent.com/juanfont/headscale/main/config-example.yaml
```

Utilizando curl:

```shell
curl https://raw.githubusercontent.com/juanfont/headscale/main/config-example.yaml -o ./config/config.yaml
```

**(Avanzado)** Si prefieres crear un archivo de configuración a mano **en lugar de** descargar el archivo de configuración de ejemplo, crea un archivo de configuración `headscale` en blanco en el directorio headscale para editarlo:

```shell
touch ./config/config.yaml
```

Modifica el archivo de configuración según tus preferencias antes de lanzar el contenedor de Docker.
Aquí tienes algunas configuraciones que probablemente quieras [aquí.](https://github.com/JDMoreu/PechiNet/blob/master/headscale/config/config.yml)

4. Inicia el servidor headscale mientras trabajas en el directorio host headscale:

Ejemplo `docker-compose.yaml`

```yaml
version: "3.7"

services:
  headscale:
    image: headscale/headscale:0.23.0-alpha5
    restart: unless-stopped
    container_name: headscale
    ports:
      - "0.0.0.0:8080:8080"
      - "0.0.0.0:9090:9090"
    volumes:
      # por favor, cambia [config_path] por la ruta completa del directorio de configuración recién creado
      - [config_path]:/etc/headscale
    command: serve

```
Montar contenedor
```shell
docker-compose -up -d
```

Nota: utiliza `0.0.0.0:8080:8080` en lugar de `127.0.0.1:8080:8080` si quieres exponer el contenedor externamente.

Este comando montará `config/` bajo `/etc/headscale`, redirigirá el puerto 8080 fuera del contenedor para que la
instancia de `headscale` esté disponible y luego se desconectará para que headscale se ejecute en segundo plano.

5. Verifica que `headscale` se está ejecutando:

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
curl http://127.0.0.1:9090/metrics
```

6. Crea un usuario ([tailnet](https://tailscale.com/kb/1136/tailnet/)):

```shell
docker exec headscale \
  headscale users create myfirstuser
```

### Registrar una máquina (inicio de sesión normal)

En una máquina cliente, ejecuta el comando `tailscale` login:

```shell
tailscale up --login-server http://ip_de_servidor:8080 --hostname=name_device
```

Para registrar una máquina cuando se ejecuta `headscale` en un contenedor, toma el comando headscale y pásalo al contenedor:

```shell
docker exec headscale \
  headscale --user myfirstuser nodes register --key <YOU_+MACHINE_KEY>
```

### Registrar máquina utilizando una clave pre-autenticada

Genera una clave utilizando la línea de comandos:

```shell
docker exec headscale \
  headscale --user myfirstuser preauthkeys create --reusable --expiration 24h
```

Esto devolverá una clave pre-autenticada que se puede utilizar para conectar un nodo a `headscale` durante el comando `tailscale`:

```shell
tailscale up --login-server <YOUR_HEADSCALE_URL> --authkey <YOUR_AUTH_KEY>
```
