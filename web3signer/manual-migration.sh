#!/bin/bash

# Exit on error
set -eo pipefail

#############
# VARIABLES #
#############

ERROR="[ ERROR-migration ]"
INFO="[ INFO-migration ]"

WORKDIR="/opt/web3signer"
MANUAL_MIGRATION_DIR="${WORKDIR}/manual_migration"
BACKUP_FILE="${MANUAL_MIGRATION_DIR}/backup.zip"
BACKUP_WALLETPASSWORD_FILE="${MANUAL_MIGRATION_DIR}/walletpassword.txt"

#############
# FUNCTIONS #
#############

# Ensure files needed for migration exists
function extract_files() {
  mkdir -p "${MANUAL_MIGRATION_DIR}"

  mv ${WORKDIR}/backup.zip ${BACKUP_FILE}

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

# Import validators with request body file
# - Docs: https://consensys.github.io/web3signer/web3signer-eth2.html#operation/KEYMANAGER_IMPORT
function import_validators() {
  import-one-by-one --keystores-path "$MANUAL_MIGRATION_DIR" --wallet-password-path "$BACKUP_WALLETPASSWORD_FILE" --network gnosis
  echo "${INFO} validators imported"
}

function empty_migration_dir() {
  rm -rf ${MANUAL_MIGRATION_DIR}/*
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
echo "${INFO} ensuring requirements"
ensure_requirements
echo "${INFO} importing validators"
import_validators
echo "${INFO} cleaning files"
empty_migration_dir
exit 0
