# Running headscale in a container

!!! warning "Community documentation"

    This page is not actively maintained by the headscale authors and is
    written by community members. It is _not_ verified by `headscale` developers.

    **It might be outdated and it might miss necessary steps**.

## Goal

This documentation has the goal of showing a user how-to set up and run `headscale` in a container.
[Docker](https://www.docker.com) is used as the reference container implementation, but there is no reason that it should
not work with alternatives like [Podman](https://podman.io). The Docker image can be found on Docker Hub [here](https://hub.docker.com/r/headscale/headscale).

## Configure and run `headscale`

1. Prepare a directory on the host Docker node in your directory of choice, used to hold `headscale` configuration and the [SQLite](https://www.sqlite.org/) database:

```shell
mkdir -p ./headscale/config
cd ./headscale
```

2. Create an empty SQlite datebase in the headscale directory:

```shell
touch ./config/db.sqlite
```

3. **(Strongly Recommended)** Download a copy of the [example configuration](https://github.com/juanfont/headscale/blob/main/config-example.yaml) from the headscale repository.

Using wget:

```shell
wget -O ./config/config.yaml https://raw.githubusercontent.com/juanfont/headscale/main/config-example.yaml
```

Using curl:

```shell
curl https://raw.githubusercontent.com/juanfont/headscale/main/config-example.yaml -o ./config/config.yaml
```

**(Advanced)** If you would like to hand craft a config file **instead** of downloading the example config file, create a blank `headscale` configuration in the headscale directory to edit:

```shell
touch ./config/config.yaml
```

Modify the config file to your preferences before launching Docker container.
Here are some settings that you likely want:

```yaml
# headscale will look for a configuration file named `config.yaml` (or `config.json`) in the following order:
#
# - `~/etc/headscale`
# - `~/.headscale`
# - current working directory

# The url clients will connect to.
# Typically this will be a domain like:
#
# https://myheadscale.example.com:443

server_url: http://your-host-name:8080

listen_addr: 0.0.0.0:8080

metrics_listen_addr: 0.0.0.0:9090

grpc_listen_addr: 127.0.0.1:50443

grpc_allow_insecure: false

noise:

  private_key_path: /etc/headscale/noise_private.key

prefixes:
  v4: 100.64.0.0/10
  v6: fd7a:115c:a1e0::/48

derp:
  server:

    enabled: false

    region_id: 999

    region_code: "headscale"
    region_name: "Headscale Embedded DERP"

    stun_listen_addr: "0.0.0.0:3478"

    private_key_path: /etc/headscale/derp_server_private.key


    automatically_add_embedded_derp_region: true

    ipv4: 1.2.3.4
    ipv6: 2001:db8::1

  urls:
    - https://controlplane.tailscale.com/derpmap/default

  paths: []

  auto_update_enabled: true

  update_frequency: 24h

disable_check_updates: false


ephemeral_node_inactivity_timeout: 30m

node_update_check_interval: 10s

database:
  type: sqlite

  # SQLite config
  sqlite:
    path: /etc/headscale/db.sqlite

acme_url: https://acme-v02.api.letsencrypt.org/directory

acme_email: ""

# Domain name to request a TLS certificate for:
tls_letsencrypt_hostname: ""


tls_letsencrypt_cache_dir: /etc/headscale/cache

tls_letsencrypt_challenge_type: HTTP-01

tls_letsencrypt_listen: ":http"

tls_cert_path: ""
tls_key_path: ""

log:

  format: text
  level: info

acl_policy_path: ""

dns_config:

  override_local_dns: true

  nameservers:
    - 1.1.1.1
    - 8.8.8.8

  domains: []

  magic_dns: true

  # `hostname.user.base_domain` (e.g., _myhost.myuser.example.com_).
  base_domain: user.headsacale.com


unix_socket: /var/run/headscale/headscale.sock
unix_socket_permission: "0770"

logtail:

  enabled: false

randomize_client_port: false
```

4. Start the headscale server while working in the host headscale directory:

Example `docker-compose.yaml`

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
      # pls change [config_path] to the fullpath of the config folder just created
      - [config_path]:/etc/headscale
    command: serve

```
Mount container
```shell
docker-compose -up -d
```

Note: use `0.0.0.0:8080:8080` instead of `127.0.0.1:8080:8080` if you want to expose the container externally.

This command will mount `config/` under `/etc/headscale`, forward port 8080 out of the container so the
`headscale` instance becomes available and then detach so headscale runs in the background.

5. Verify `headscale` is running:

Follow the container logs:

```shell
docker logs --follow headscale
```

Verify running containers:

```shell
docker ps
```

Verify `headscale` is available:

```shell
curl http://127.0.0.1:9090/metrics
```

6. Create a user ([tailnet](https://tailscale.com/kb/1136/tailnet/)):

```shell
docker exec headscale \
  headscale users create myfirstuser
```

### Register a machine (normal login)

On a client machine, execute the `tailscale` login command:

```shell
tailscale up --login-server http://ip_de_servidor:8080 --hostname=name_device
```

To register a machine when running `headscale` in a container, take the headscale command and pass it to the container:

```shell
docker exec headscale \
  headscale --user myfirstuser nodes register --key <YOU_+MACHINE_KEY>
```

### Register machine using a pre authenticated key

Generate a key using the command line:

```shell
docker exec headscale \
  headscale --user myfirstuser preauthkeys create --reusable --expiration 24h
```

This will return a pre-authenticated key that can be used to connect a node to `headscale` during the `tailscale` command:

```shell
tailscale up --login-server <YOUR_HEADSCALE_URL> --authkey <YOUR_AUTH_KEY>
```

