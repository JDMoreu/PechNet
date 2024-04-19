# Configuración Servidor local

## Instalar y configurar Tailscale en tu equipo local

Puedes instalar [Tailcale](https://tailscale.com/) desde la pagina oficional, en linux puedes instalarlo con:

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```
Puedes verificar que este instalado con:

```bash
tailscale --version
```
### Una vez instalado al que en la VPS puedes usar cualquiera de los 2 metodos de conexion:

- **1. Registrar una máquina (inicio de sesión normal)**

En máquina local cliente, ejecuta el comando `tailscale` login:

```shell
#Ejecutar en la maquina local
tailscale up --login-server http://ip_de_servidor:8080 --hostname=name_device
```

Para registrar una máquina donde se ejecuta `headscale` en el contenedor de la VPS, toma el comando headscale y pásalo al contenedor:

```shell
#Ejecutar en la VPS
docker exec headscale \
headscale --user myfirstuser nodes register --key <TU_CLAVE_DE_MAQUINA>
```

- **2. Registrar máquina utilizando una clave pre-autenticada**

Genera una clave utilizando la línea de comandos `VPS`:

```shell
# Ejecutar en la VPS
docker exec headscale \
headscale --user myfirstuser preauthkeys create --reusable --expiration 24h
```

Esto devolverá una clave pre-autenticada que se puede utilizar para conectar a un nodo `headscale` durante el comando `tailscale`:

```shell
# Ejecutar en el cliente local
tailscale up --login-server <TU_URL_HEADSCALE> --authkey <TU_CLAVE_DE_AUTENTICACION>
```
Puedes verificar que estas conectado a la red de `headscale` con:

```shell
# Ejecutar en el cliente local
tailscale status
```

## Configurar [Redireccionamiento del trafico VPS al Servidor Local](/config_local.md)
