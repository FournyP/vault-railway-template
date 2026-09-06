FROM hashicorp/vault:2.1

# The official Vault 2.x images end with `USER vault`. The build steps below
# need root, and the entrypoint drops privileges itself at runtime.
USER root

ARG STORAGE_PATH
ARG DEFAULT_LEASE_TTL
ARG MAX_LEASE_TTL
ARG UI_ENABLED
ARG PORT=8200
ENV ENV=dev
ENV STORAGE_PATH=${STORAGE_PATH}

COPY config.sh /config.sh
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /config.sh /entrypoint.sh && \
    export STORAGE_PATH=${STORAGE_PATH} && \
    export DEFAULT_LEASE_TTL=${DEFAULT_LEASE_TTL} && \
    export MAX_LEASE_TTL=${MAX_LEASE_TTL} && \
    export UI_ENABLED=${UI_ENABLED} && \
    export PORT=${PORT} && \
    /config.sh

RUN mv ./config.json /vault/config/config.json

ENTRYPOINT ["/entrypoint.sh"]
