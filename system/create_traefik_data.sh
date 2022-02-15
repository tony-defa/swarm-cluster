#!/bin/bash

DATA_PATH=$(cat .env | grep "HOST_TRAEFIK_PATH" | cut -d'=' -f2)

mkdir -p $DATA_PATH

touch "${DATA_PATH}/users.txt"
touch "${DATA_PATH}/acme.json"

chmod 600 "${DATA_PATH}/users.txt"
chmod 600 "${DATA_PATH}/acme.json"

tee -a "${DATA_PATH}/dynamic.yml" > /dev/null <<EOF
# Dynamic configuration
http:
  middlewares:
    secureHeaders:
      headers:
        sslRedirect: true
        forceSTSHeader: true
        stsIncludeSubdomains: true
        stsPreload: true
        stsSeconds: 31536000

    user-auth:
      basicAuth:
        usersFile: "/data/users.txt"

tls:
  options:
    default:
      cipherSuites:
        - TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
        - TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
        - TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
        - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
        - TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305
        - TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305
      minVersion: VersionTLS12
EOF

chown -R :docker $DATA_PATH