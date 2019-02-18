# Apache FPM container based on phusion
Simple apache-vhost that serves content from /var/www/web - php-requests are
proxied to a linked fpm-container named "fpm" on port 9000.

# mkcert

This image has [mkcert](https://github.com/FiloSottile/mkcert)
builtin.

Run `mkcert -install` on your host machine.

Then you add the generated CAROOT as a volume (the path on the host
machine is the output of `mkcert -CAROOT`).

In your `docker-compose.yml` supply one or more host names to be be
used for HTTPS in either:

1. environment variable `MKCERT_DOMAINS`,
1. the environment variable `VIRTUAL_HOST`, or
1. as `hostname` and `domainname` configuration

```yaml
    volumes:
      - '${HOME}/Library/Application Support/mkcert:/mkcert/mac:ro'
      - '${HOME}/.local/share/mkcert:/mkcert/linux:ro'

    environment:
      MKCERT_DOMAINS: "example.docker *.example.docker local.docker"
      VIRTUAL_HOST: example.docker

    hostname: example
    domainname: docker
```
