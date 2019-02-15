#!/bin/bash

set -euo pipefail

export CAROOT=/mkcert

if [[ ! -r "${CAROOT}/rootCA.pem" ]] && [[ ! -r "${CAROOT}/rootCA-key.pem" ]]; then
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
