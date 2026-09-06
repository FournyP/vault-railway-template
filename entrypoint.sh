#!/bin/sh

PORT="${PORT:-8200}"
STORAGE_PATH="${STORAGE_PATH:-/vault/file}"

# Vault 2.x images run Vault as the unprivileged `vault` user, but Railway
# mounts volumes as root. The container therefore starts as root so it can fix
# ownership of the data directory, then hands off to the `vault` user.
run_as_vault() {
    if [ "$(id -u)" = "0" ]; then
        exec su-exec vault "$@"
    fi
    exec "$@"
}

if [ "$ENV" = "dev" ]; then
    export VAULT_DEV_LISTEN_ADDRESS="[::]:${PORT}"
    export VAULT_DEV_ROOT_TOKEN_ID="${DEV_ROOT_TOKEN_ID}"
    run_as_vault vault server --dev
else
    if [ "$(id -u)" = "0" ]; then
        mkdir -p "$STORAGE_PATH"
        if [ "$(stat -c %u "$STORAGE_PATH")" != "$(id -u vault)" ]; then
            echo "Taking ownership of ${STORAGE_PATH} for the vault user"
            chown -R vault:vault "$STORAGE_PATH"
        fi
    fi
    run_as_vault vault server -config=/vault/config/config.json
fi
