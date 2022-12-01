#!/bin/bash

export KEYFILES_DIR="/data/keyfiles"
export NETWORK="gnosis"
export WEB3SIGNER_API="http://web3signer.web3signer-${NETWORK}.dappnode:9000"

# Assign proper value to _DAPPNODE_GLOBAL_CONSENSUS_CLIENT_GNOSIS. The UI uses the web3signer domain in the Header "Host"
case "$_DAPPNODE_GLOBAL_CONSENSUS_CLIENT_GNOSIS" in
"gnosis-beacon-chain-prysm.dnp.dappnode.eth")
  ETH2_CLIENT_DNS="validator.gnosis-beacon-chain-prysm.dappnode"
  export BEACON_NODE_API="http://beacon-chain.gnosis-beacon-chain-prysm.dappnode:3500"
  export CLIENT_API="http://validator.gnosis-beacon-chain-prysm.dappnode:3500"
  export TOKEN_FILE="/security/prysm/auth-token"
  export CLIENTS_TO_REMOVE=(teku lighthouse)
  ;;
"teku-gnosis.dnp.dappnode.eth")
  ETH2_CLIENT_DNS="validator.teku-gnosis.dappnode"
  export BEACON_NODE_API="http://beacon-chain.teku-gnosis.dappnode:3500"
  export CLIENT_API="https://validator.teku-gnosis.dappnode:3500"
  export TOKEN_FILE="/security/teku/validator-api-bearer"
  export CLIENTS_TO_REMOVE=(lighthouse prysm)
  ;;
"lighthouse-gnosis.dnp.dappnode.eth")
  ETH2_CLIENT_DNS="validator.lighthouse-gnosis.dappnode"
  export BEACON_NODE_API="http://beacon-chain.lighthouse-gnosis.dappnode:3500"
  export CLIENT_API="http://validator.lighthouse-gnosis.dappnode:3500"
  export TOKEN_FILE="/security/lighthouse/api-token.txt"
  export CLIENTS_TO_REMOVE=(teku prysm)
  ;;
*)
  echo "_DAPPNODE_GLOBAL_CONSENSUS_CLIENT_GNOSIS env is not set propertly"
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

# delete all the pubkeys from the all the clients (excluding the client selected)
/usr/bin/delete-keys.sh "${CLIENTS_TO_REMOVE[@]}"

# IMPORTANT! The dir defined for --key-store-path must exist and have specific permissions. Should not be created with a docker volume
mkdir -p "$KEYFILES_DIR"
mkdir -p "/opt/web3signer/manual_migration"

if grep -Fq "/opt/web3signer/keyfiles" ${KEYFILES_DIR}/*.yaml; then
  sed -i "s|/opt/web3signer/keyfiles|$KEYFILES_DIR|g" ${KEYFILES_DIR}/*.yaml
fi

# inotify manual migration
while inotifywait -e close_write --include 'backup\.zip' /opt/web3signer; do
  /usr/bin/manual-migration.sh
done &
disown

# inotify reload keys
while inotifywait -r -e modify,create,delete "$KEYFILES_DIR"; do
  # Add a delay to prevent from executing the script too often
  # sleep before the script to execute the script with the more pubkeys imported/deleted possible
  sleep 5
  /usr/bin/reload-keys.sh
done &
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
  --http-host-allowlist="web3signer.web3signer-gnosis.dappnode,web3signer.web3signer-gnosis.dappnode,prysm.migration-gnosis.dappnode,$ETH2_CLIENT_DNS" \
  --http-cors-origins=* \
  --metrics-enabled=true \
  --metrics-host 0.0.0.0 \
  --metrics-port 9091 \
  --metrics-host-allowlist="*" \
  --idle-connection-timeout-seconds=90 \
  eth2 \
  --network=gnosis \
  --slashing-protection-db-url=jdbc:postgresql://postgres.web3signer-gnosis.dappnode:5432/web3signer-gnosis \
  --slashing-protection-db-username=postgres \
  --slashing-protection-db-password=gnosis \
  --slashing-protection-pruning-enabled=true \
  --slashing-protection-pruning-epochs-to-keep=225 \
  --key-manager-api-enabled=true \
  ${EXTRA_OPTS}
