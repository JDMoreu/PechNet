# Configuración redireccionamiento de trafico VPS a Servidor 

## Ejecutar los siguientes comandos en la VPS:

**1. Instalar net-tools:**

```shell
apt install net-tools -y
```

**2. Habilitar el renvio de paquetes IP:**

```shell
echo 1 > /proc/sys/net/ipv4/ip_forward
```

**3. Verificar la ruta predeterminada existente:**

```shell
route -n
```
## Redireccionar todo el trafico de la VPS al Servidor local

```shell
iptables -t nat -A PREROUTING -i [dispositivo-de-red] -j DNAT --to-destination [ip-local-red-tailscale]
# Ejemplo: iptables -t nat -A PREROUTING -i enp0s6 -j DNAT --to-destination 100.64.0.4
iptables -t nat -A POSTROUTING -o tailscale0 -j MASQUERADE
iptables -A FORWARD -i [dispositivo-de-red] -o tailscale0 -m state --state RELATED,ESTABLISHED -j ACCEPT
# Ejemplo: iptables -A FORWARD -i enp0s6 -o tailscale0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i tailscale0 -o [dispositivo-de-red] -j ACCEPT
# Ejemplo: iptables -A FORWARD -i tailscale0 -o enp0s6 -j ACCEPT
```

## Redireccionar el trafico de un puerto de la VPS al Servidor local

```shell
iptables -t nat -A PREROUTING -i [dispositivo-de-red] -p tcp --dport [puerto] -j DNAT --to-destination [ip-local-red-tailscale]
# Ejemplo: iptables -t nat -A PREROUTING -i enp0s6 -p tcp --dport 80 -j DNAT --to-destination 100.64.0.4
iptables -A FORWARD -i [dispositivo-de-red] -p tcp --dport [puerto] -d [ip-local-red-tailscale] -j ACCEPT
# Ejemplo: iptables -A FORWARD -i enp0s6 -p tcp --dport 80 -d 100.64.0.4 -j ACCEPT
iptables -A FORWARD -o [dispositivo-de-red] -p tcp --sport [puerto] -s [ip-local-red-tailscale] -j ACCEPT
# Ejemplo: iptables -A FORWARD -o enp0s6 -p tcp --sport 80 -s 100.64.0.4 -j ACCEPT
```

## Acceder a mi Servidor Local desde internet

Solo debes usar la ip publica de tu VPS más el puesto o los puertos que configuraste anterirormente.

Si haces uan petición a la vps este redireccionara el trafico a tu ip local por medio de la red tailscale. **Ejemplo**: 

	`150.134.170.21:8080` >> `100.64.0.4:8080` >> `localhost:8080`