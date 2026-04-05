FROM hashicorp/vault:1.21

ARG STORAGE_PATH
ARG DEFAULT_LEASE_TTL
ARG MAX_LEASE_TTL
ARG UI_ENABLED
ENV ENV=dev

COPY config.sh /config.sh
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /config.sh /entrypoint.sh && \
    export STORAGE_PATH=${STORAGE_PATH} && \
    export DEFAULT_LEASE_TTL=${DEFAULT_LEASE_TTL} && \
    export MAX_LEASE_TTL=${MAX_LEASE_TTL} && \
    export UI_ENABLED=${UI_ENABLED} && \
    /config.sh

RUN mv ./config.json /vault/config/config.json

ENTRYPOINT ["/entrypoint.sh"]
