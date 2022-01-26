#!/bin/bash

KEYFILES_DIR="/opt/web3signer/keyfiles"
mkdir -p "$KEYFILES_DIR"

# Run web3signer binary
# - Run key manager (it may change in the future): --key-manager-api-enabled=true
exec /opt/web3signer/bin/web3signer --key-store-path="$KEYFILES_DIR" --http-listen-port=9003 --http-listen-host=0.0.0.0 --http-host-allowlist=* eth2 --network=prater --slashing-protection-db-url=jdbc:postgresql://postgres:5432/web3signer --slashing-protection-db-username=postgres --slashing-protection-db-password=password --key-manager-api-enabled=true