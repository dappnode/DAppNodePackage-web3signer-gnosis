#!/bin/bash

export KEYFILES_DIR="/opt/web3signer/keyfiles"
export NETWORK="prater"
export WEB3SIGNER_API="http://web3signer.web3signer-${NETWORK}.dappnode:${SIGNER_PORT}"

# Assign proper value to ETH2_CLIENT. The UI uses the web3signer domain in the Header "Host"
case "$ETH2_CLIENT" in
"prysm")
  ETH2_CLIENT_DNS="validator.prysm-prater.dappnode"
  export BEACON_NODE_API="http://beacon-chain.prysm-prater.dappnode:3500"
  export CLIENT_API="http://validator.prysm-prater.dappnode:3500"
  export TOKEN_FILE="/security/prysm/auth-token"
  ;;
"teku")
  ETH2_CLIENT_DNS="validator.teku-prater.dappnode"
  export BEACON_NODE_API="http://beacon-chain.teku-prater.dappnode:3500"
  export CLIENT_API="https://validator.teku-prater.dappnode:3500"
  export TOKEN_FILE="/security/teku/validator-api-bearer"
  ;;
"lighthouse")
  ETH2_CLIENT_DNS="validator.lighthouse-prater.dappnode"
  export BEACON_NODE_API="http://beacon-chain.lighthouse-prater.dappnode:3500"
  export CLIENT_API="http://validator.lighthouse-prater.dappnode:3500"
  export TOKEN_FILE="/security/lighthouse/auth-token"
  ;;
"nimbus")
  ETH2_CLIENT_DNS="beacon-validator.nimbus-prater.dappnode"
  export BEACON_NODE_API="http://beacon-validator.nimbus-prater.dappnode:4500"
  export CLIENT_API="http://beacon-validator.nimbus-prater.dappnode:3500"
  export TOKEN_FILE="/security/nimbus/auth-token"
  ;;
"all")
  ETH2_CLIENT_DNS="*"
  ;;
*)
  echo "ETH2_CLIENT env is not set propertly"
  exit 1
  ;;
esac

if [[ $LOG_TYPE == "DEBUG" ]]; then
  export LOG_LEVEL=0
elif [[ $LOG_TYPE == "INFO" ]]; then
  export LOG_LEVEL=1
elif [[ $LOG_TYPE == "WARN" ]]; then
  export LOG_LEVEL=2
elif [[ $LOG_TYPE == "ERROR" ]]; then
  export LOG_LEVEL=3
else
  export LOG_LEVEL=1
fi

# IMPORTANT! The dir defined for --key-store-path must exist and have specific permissions. Should not be created with a docker volume
mkdir -p "$KEYFILES_DIR"

# Loads envs into /etc/environment to be used by the reload-keys.sh script
env >>/etc/environment

# start watch-keys and disown it
watch-keys.sh &
disown

# Run web3signer binary
# - Run key manager (it may change in the future): --key-manager-api-enabled=true
exec /opt/web3signer/bin/web3signer \
  --key-store-path="$KEYFILES_DIR" \
  --http-listen-port=9000 \
  --http-listen-host=0.0.0.0 \
  --http-host-allowlist="web3signer.web3signer-prater.dappnode,$ETH2_CLIENT_DNS" \
  --http-cors-origins=* \
  --metrics-enabled=true \
  --metrics-host 0.0.0.0 \
  --metrics-port 9091 \
  --metrics-host-allowlist="*" \
  eth2 \
  --network=prater \
  --slashing-protection-db-url=jdbc:postgresql://postgres:5432/web3signer \
  --slashing-protection-db-username=postgres \
  --slashing-protection-db-password=password \
  --key-manager-api-enabled=true \
  ${EXTRA_OPTS}
