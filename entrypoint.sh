#!/bin/sh

PORT="${PORT:-8200}"

if [ "$ENV" = "dev" ]; then
    VAULT_DEV_LISTEN_ADDRESS="[::]:${PORT}" \
    VAULT_DEV_ROOT_TOKEN_ID="${DEV_ROOT_TOKEN_ID}" \
    exec vault server --dev
else
    exec vault server -config=/vault/config/config.json
fi
