#!/bin/bash

set -euo pipefail

CAROOT="$(find /mkcert -type d -exec sh -c '[ -f "$0"/rootCA.pem ] && [ -f "$0"/rootCA-key.pem ]' '{}' \; -print)"
export CAROOT

if [[ -z "${CAROOT}" ]]; then
    exit 0;
fi

MKCERT_DOMAINS="${MKCERT_DOMAINS:-${VIRTUAL_HOST:-$(hostname -f)}}"

if [[ -z "${MKCERT_DOMAINS}" ]]; then
    exit 0;
fi

IFS=' ' read -r -a MKCERT_DOMAINS <<< "${MKCERT_DOMAINS}"

# Install the CA certificate in the Docker containers system trust
# store. Mostly we do that to ignore warnings about the CA not being
# installed when generating certificates later (but also to trust the
# certificates from within).
/usr/local/bin/mkcert -install

# Run `mkcert` to generate certificate and key.
/usr/local/bin/mkcert -cert-file /etc/ssl/certs/ssl-cert-snakeoil.pem -key-file /etc/ssl/private/ssl-cert-snakeoil.key "${MKCERT_DOMAINS[@]}"

# Expose the generated certificate in /cert named after the first
# domain name (compatible with Dory / nginx-proxy).
for domain in "${MKCERT_DOMAINS[@]}"
do
    # Strip wildcard.
    domain="${domain#\*\.}"
    cp /etc/ssl/certs/ssl-cert-snakeoil.pem "/cert/${domain}.crt"
    cp /etc/ssl/private/ssl-cert-snakeoil.key "/cert/${domain}.key"
done
