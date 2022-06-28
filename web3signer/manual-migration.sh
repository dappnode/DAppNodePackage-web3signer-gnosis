#!/bin/bash

# Exit on error
set -eo pipefail

#############
# VARIABLES #
#############

ERROR="[ ERROR-migration ]"
INFO="[ INFO-migration ]"

MANUAL_MIGRATION_DIR="/opt/web3signer/manual_migration"
BACKUP_FILE="${MANUAL_MIGRATION_DIR}/backup.zip"
BACKUP_WALLETPASSWORD_FILE="${MANUAL_MIGRATION_DIR}/walletpassword.txt"
REQUEST_BODY_FILE="${MANUAL_MIGRATION_DIR}/request_body.json"

#############
# FUNCTIONS #
#############

# Ensure files needed for migration exists
function extract_files() {
  # Check if wallet password file exists
  if [ ! -f "${BACKUP_FILE}" ]; then
    {
      echo "${ERROR} ${BACKUP_FILE} not found"
      empty_migration_dir
      exit 1
    }
  fi

  unzip -d "${MANUAL_MIGRATION_DIR}" "${BACKUP_FILE}" || {
    echo "${ERROR} failed to unzip keystores, manual migration required"
    empty_migration_dir
    exit 1
  }
}

# Ensure requirements
function ensure_requirements() {
  # Try for 3 minutes
  # Check if web3signer is available: https://consensys.github.io/web3signer/web3signer-eth2.html#tag/Server-Status
  if [ "$(curl -s -X GET \
    -H "Content-Type: application/json" \
    -H "Host: prysm.migration-gnosis.dappnode" \
    --write-out '%{http_code}' \
    --silent \
    --output /dev/null \
    --retry 60 \
    --retry-delay 3 \
    --retry-all-errors \
    "${WEB3SIGNER_API}/upcheck")" == 200 ]; then
    echo "${INFO} web3signer available"
  else
    {
      echo "${ERROR} web3signer not available after 3 minutes, manual migration required"
      empty_migration_dir
      exit 1
    }
  fi
}

# Create request body file
# - It cannot be used as environment variable because the slashing data might be too big resulting in the error: Error list too many arguments
# - Exit if request body file cannot be created
function create_request_body_file() {
  echo '{}' | jq '{ keystores: [], passwords: [] }' >"$REQUEST_BODY_FILE"
  KEYSTORE_FILES=($(ls "${MANUAL_MIGRATION_DIR}"/*.json))
  for KEYSTORE_FILE in "${KEYSTORE_FILES[@]}"; do
    echo $(jq --slurpfile keystore ${KEYSTORE_FILE} '.keystores += [$keystore[0]|tojson]' ${REQUEST_BODY_FILE}) >${REQUEST_BODY_FILE}
    echo $(jq --arg walletpassword "$(cat ${BACKUP_WALLETPASSWORD_FILE})" '.passwords += [$walletpassword]' ${REQUEST_BODY_FILE}) >${REQUEST_BODY_FILE}
  done
}

# Import validators with request body file
# - Docs: https://consensys.github.io/web3signer/web3signer-eth2.html#operation/KEYMANAGER_IMPORT
function import_validators() {
  curl -X POST \
    -d @"${REQUEST_BODY_FILE}" \
    --retry 60 \
    --retry-delay 3 \
    --retry-all-errors \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -H "Host: prysm.migration-gnosis.dappnode" \
    "${WEB3SIGNER_API}"/eth/v1/keystores

  echo "${INFO} validators imported"
}

function empty_migration_dir() {
  rm -rf "${MANUAL_MIGRATION_DIR}/*"
}

########
# MAIN #
########

error_handling() {
  echo 'Error raised. Cleaning validator volume and exiting'
  empty_migration_dir
}

trap 'error_handling' ERR

echo "${INFO} extracting files"
extract_files
echo "${INFO} creating request body"
create_request_body_file
echo "${INFO} ensuring requirements"
ensure_requirements
echo "${INFO} importing validators"
import_validators

exit 0
