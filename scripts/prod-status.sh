#!/usr/bin/env bash

set -Eeuo pipefail

echo "== Docker containers =="
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
echo
echo "== Frontend =="
curl -sSI https://phapmontamlinh-quantheambotat.vn/ | head -n 1
echo "== Strapi Admin =="
if ! curl -sSI https://strapi.phapmontamlinh-quantheambotat.vn/admin 2>/dev/null | head -n 1; then
  curl -ksSI https://strapi.phapmontamlinh-quantheambotat.vn/admin | head -n 1
fi
