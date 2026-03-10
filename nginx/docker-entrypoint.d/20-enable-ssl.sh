#!/usr/bin/env sh
set -eu

DOMAIN="phapmontamlinh-quantheambotat.vn"

CERT_DIR="/etc/letsencrypt/live/${DOMAIN}"
CERT="${CERT_DIR}/fullchain.pem"
KEY="${CERT_DIR}/privkey.pem"

SSL_DIR="/etc/nginx/conf.d/ssl"
DISABLED_CONF="${SSL_DIR}/pmtl-ssl.conf.disabled"
ENABLED_CONF="${SSL_DIR}/pmtl-ssl.conf"

mkdir -p "${SSL_DIR}"

if [ -f "${CERT}" ] && [ -f "${KEY}" ]; then
  if [ -f "${DISABLED_CONF}" ]; then
    cp -f "${DISABLED_CONF}" "${ENABLED_CONF}"
    echo "[pmtl] SSL enabled: found certs for ${DOMAIN}"
  else
    echo "[pmtl] SSL not enabled: missing ${DISABLED_CONF}"
  fi
else
  rm -f "${ENABLED_CONF}" || true
  echo "[pmtl] SSL not enabled: certs not found for ${DOMAIN}"
fi

exit 0
