echo "
{
  \"storage\": { \"file\": { \"path\": \"${STORAGE_PATH}\" } },
  \"listener\": [{ \"tcp\": { \"address\": \"[::]:${PORT}\", \"tls_disable\": \"true\" } }],
  \"default_lease_ttl\": \"${DEFAULT_LEASE_TTL}\",
  \"max_lease_ttl\": \"${MAX_LEASE_TTL}\",
  \"ui\": ${UI_ENABLED},
  \"disable_mlock\": true
}
" > config.json
