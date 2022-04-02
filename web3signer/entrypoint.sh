#!/bin/bash

# Check envs exist
[ -z "$KEYFILES_DIR" ] && echo "KEYFILES_DIR env is not set" && exit 1
[ -z "$SIGNER_PORT" ] && echo "SIGNER_PORT env is not set" && exit 1
[ -z "$ETH2_CLIENT" ] && echo "ETH2_CLIENT env is not set" && exit 1

# Assign proper value to ETH2_CLIENT. The UI uses the web3signer domain in the Header "Host"
case "$ETH2_CLIENT" in
  "prysm")
    ETH2_CLIENT="web3signer.web3signer-prater.dappnode,validator.prysm-prater.dappnode"
    ;;
  "teku")
    ETH2_CLIENT="web3signer.web3signer-prater.dappnode,validator.teku-prater.dappnode"
    ;;
  "lighthouse")
    ETH2_CLIENT="web3signer.web3signer-prater.dappnode,validator.lighthouse-prater.dappnode"
    ;;
  "nimbus")
    ETH2_CLIENT="web3signer.web3signer-prater.dappnode,validator.nimbus-prater.dappnode"
    ;;
  "all")
    ETH2_CLIENT="*"
    ;;
  *)
    echo "ETH2_CLIENT env is not set propertly"
    ETH2_CLIENT="none"
    ;;
esac
    
# IMPORTANT! The dir defined for --key-store-path must exist and have specific permissions. Should not be created with a docker volume
mkdir -p "$KEYFILES_DIR"

# Run web3signer binary
# - Run key manager (it may change in the future): --key-manager-api-enabled=true
exec /opt/web3signer/bin/web3signer \
    --key-store-path="$KEYFILES_DIR" \
    --http-listen-port="$SIGNER_PORT" \
    --http-listen-host=0.0.0.0 \
    --http-host-allowlist="$ETH2_CLIENT" \
    --http-cors-origins=* \
    eth2 \
    --network=prater \
    --slashing-protection-db-url=jdbc:postgresql://postgres:5432/web3signer \
    --slashing-protection-db-username=postgres \
    --slashing-protection-db-password=password \
    --key-manager-api-enabled=true \
    --metrics-enabled \
    --metrics-host 0.0.0.0 \
    --metrics-port 9091 \
    --metrics-host-allowlist "*" \
    ${EXTRA_OPTS}