#!/bin/bash

set -euo pipefail

# Try to locate `rootCA.pem` and `rootCA-key.pem` in a folder beneath
# `/mkcert`.
CAROOT="$(find /mkcert -type d -exec sh -c '[ -f "$0"/rootCA.pem ] && [ -f "$0"/rootCA-key.pem ]' '{}' \; -print)"
export CAROOT

# If no root CA found just exit now without generating any
# certificates.
if [[ -z "${CAROOT}" ]]; then
    exit 0;
fi

# If no VIRTUAL_HOST is set use `hostname -f` as fallback.
VIRTUAL_HOST="${VIRTUAL_HOST:-$(hostname -f)}"

# Dinghys wildcard syntax is prefixing only with a dot (as in
# `.example.com`). We rewrite those to use an asterisk as expected by
# mkcert (`*.example.com`).
VIRTUAL_HOST="${VIRTUAL_HOST/#./*.}"

# If on MKCERT_DOMAINS is set use VIRTUAL_HOST as fallback.
MKCERT_DOMAINS="${MKCERT_DOMAINS:-${VIRTUAL_HOST}}"

# If we couldn't find any domain names just exit now without
# generating any certificates.
if [[ -z "${MKCERT_DOMAINS}" ]]; then
    exit 0;
fi

# Split a space separated string into a bash array.
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
