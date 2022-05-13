#!/bin/bash

export KEYFILES_DIR="/opt/web3signer/keyfiles"
export NETWORK="gnosis"
export WEB3SIGNER_API="http://web3signer.web3signer-${NETWORK}.dappnode:9000"

# Assign proper value to ETH2_CLIENT. The UI uses the web3signer domain in the Header "Host"
case "$ETH2_CLIENT" in
"prysm")
  ETH2_CLIENT_DNS="validator.prysm-gnosis.dappnode"
  export BEACON_NODE_API="http://beacon-chain.prysm-gnosis.dappnode:3500"
  export CLIENT_API="http://validator.prysm-gnosis.dappnode:3500"
  export TOKEN_FILE="/security/prysm/auth-token"
  ;;
"teku")
  ETH2_CLIENT_DNS="validator.teku-gnosis.dappnode"
  export BEACON_NODE_API="http://beacon-chain.teku-gnosis.dappnode:3500"
  export CLIENT_API="https://validator.teku-gnosis.dappnode:3500"
  export TOKEN_FILE="/security/teku/validator-api-bearer"
  ;;
"lighthouse")
  ETH2_CLIENT_DNS="validator.lighthouse-gnosis.dappnode"
  export BEACON_NODE_API="http://beacon-chain.lighthouse-gnosis.dappnode:3500"
  export CLIENT_API="http://validator.lighthouse-gnosis.dappnode:3500"
  export TOKEN_FILE="/security/lighthouse/auth-token"
  ;;
"nimbus")
  ETH2_CLIENT_DNS="beacon-validator.nimbus-gnosis.dappnode"
  export BEACON_NODE_API="http://beacon-validator.nimbus-gnosis.dappnode:4500"
  export CLIENT_API="http://beacon-validator.nimbus-gnosis.dappnode:3500"
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

# Loads envs into /etc/environment to be used by the reload-keys.sh script
env >>/etc/environment

# IMPORTANT! The dir defined for --key-store-path must exist and have specific permissions. Should not be created with a docker volume
mkdir -p "$KEYFILES_DIR"

# start watch-keys and disown it
inotifywait -e modify,create,delete -r "$KEYFILES_DIR" && /usr/bin/reload-keys.sh &
disown

# start cron
cron -f &
disown

# Run web3signer binary
# - Run key manager (it may change in the future): --key-manager-api-enabled=true
exec /opt/web3signer/bin/web3signer \
  --key-store-path="$KEYFILES_DIR" \
  --http-listen-port=9000 \
  --http-listen-host=0.0.0.0 \
  --http-host-allowlist="web3signer.web3signer-gnosis.dappnode,$ETH2_CLIENT_DNS" \
  --http-cors-origins=* \
  --metrics-enabled=true \
  --metrics-host 0.0.0.0 \
  --metrics-port 9091 \
  --metrics-host-allowlist="*" \
  eth2 \
  --network=gnosis \
  --slashing-protection-db-url=jdbc:postgresql://postgres:5432/web3signer \
  --slashing-protection-db-username=postgres \
  --slashing-protection-db-password=password \
  --key-manager-api-enabled=true \
  ${EXTRA_OPTS}
