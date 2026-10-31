#!/usr/bin/env bash
# Generate throwaway self-signed TLS certs (CN=localhost) for the local Mosquitto test broker.
# These are NOT committed (see .gitignore); they exist only to exercise the TLS code paths locally.
# Requires openssl. Safe to re-run: does nothing if the certs already exist.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p certs
cd certs
if [ -f server.key ] && [ -f server.crt ] && [ -f ca.crt ]; then
  exit 0
fi
openssl req -x509 -newkey rsa:2048 -nodes -keyout ca.key -out ca.crt -days 3650 -subj "/CN=mqtt-mcp-test-ca" 2>/dev/null
openssl req -newkey rsa:2048 -nodes -keyout server.key -out server.csr -subj "/CN=localhost" 2>/dev/null
printf 'subjectAltName=DNS:localhost,IP:127.0.0.1\n' > server.ext
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 3650 -extfile server.ext 2>/dev/null
rm -f server.csr server.ext ca.srl
# The broker container runs as a non-root user and mounts this directory read-only.
chmod 644 ca.key server.key ca.crt server.crt
