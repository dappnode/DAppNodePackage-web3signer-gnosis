#!/bin/bash

# Detect new keystores and password from KEYFILES_DIR_TMP and move them to KEYFILES_DIR
# following naming convention: keystore<number>.json

# Log vars
INFO="\e[0;34m[INFO] "
WARNING="\e[0;33m [WARN] "
ERROR="\e[0;31m [ERROR] "
END_LOG="\e[0m"

# VARS
#KEYFILES_DIR_TMP="/home/dappnode/test/tmp"
#KEYFILES_DIR="/home/dappnode/test/keyfiles"
KEYSTORE_FILES_TMP=$(ls $KEYFILES_DIR_TMP/*.json)
KEYSTORE_FILES=$(ls $KEYFILES_DIR/*.json)
KEYSTORE_PASSWORD_FILE_TMP=$(ls $KEYFILES_DIR_TMP/*.txt)
PASSWORD_FILE_NAME="password_"
ARRAY_NEW_KEYSTORES=()

# Check requirements
function check_requirements() {
    [ -z "$KEYSTORE_FILES_TMP" ] && [ ! -z "$KEYSTORE_PASSWORD_FILE_TMP" ] && { echo -e "${ERROR} password uploaded without keystores ${END_LOG}"; exit 1;}
    [ -z "$KEYSTORE_PASSWORD_FILE_TMP" ] && [ ! -z "$KEYSTORE_FILES_TMP" ] && { echo -e "${ERROR} keystores uploaded without password ${END_LOG}"; exit 1;}
}

# Create validator file
function create_validator_file() {
    echo -e "${INFO} creating validator file ${END_LOG}"
    printf 'type: "file-keystore"\nkeyType: "BLS"\nkeystoreFile: "%s"\nkeystorePasswordFile: "%s"\n' "${KEYFILES_DIR}/keystore_${1}.json" "${KEYFILES_DIR}/${PASSWORD_FILE_NAME}.txt" >> validator_${1}.yml
}

# Moves keystore files from KEYFILES_DIR_TMP to KEYFILES_DIR
function move_keys_files() {
    counter=1
    KEY_FILE_NAME="keystore_${counter}.json"

    for KEY_FILE_TMP in $KEYSTORE_FILES_TMP; do
        # Move new KEY_FILE_TMP and look for an available name  
        # Check if file content is same with cmp??
        # while 
        while [ -f ${KEYFILES_DIR}/${KEY_FILE_NAME} ]; do
            ((counter+=1))
            KEY_FILE_NAME="keystore_${counter}.json"
        done

        if [ ! -f ${KEYFILES_DIR}/${KEY_FILE_NAME} ]; then
            echo -e "${INFO} moving ${KEY_FILE_TMP} ${END_LOG}"
            mv ${KEY_FILE_TMP} ${KEYFILES_DIR}/${KEY_FILE_NAME} || { echo -e "${ERROR} failed to move ${KEY_FILE_TMP} to ${KEYFILES_DIR} ${END_LOG}"; exit 1;}
            ARRAY_NEW_KEYSTORES+=($counter)
            PASSWORD_FILE_NAME+=$counter
        fi
    done

    # Move KEYSTORE_PASSWORD_FILE to KEYFILES_DIR
    mv ${KEYSTORE_PASSWORD_FILE_TMP} ${KEYFILES_DIR}/${PASSWORD_FILE_NAME}.txt || { echo -e "${ERROR} failed to move ${KEYSTORE_PASSWORD_FILE} to ${KEYFILES_DIR} ${END_LOG}"; exit 1;} 
}

##########
## MAIN ##
##########

check_requirements

if [ -z "$KEYSTORE_FILES_TMP" ]; then
    # Skip if no new files found in tmp dir
    echo -e "${INFO} no new keystore files found in ${KEYFILES_DIR_TMP} ${END_LOG}"
else
    # Move new files if found in tmp dir and create the validator_x.yml file
    echo -e "${INFO} moving keystore files from ${KEYFILES_DIR_TMP} to ${KEYFILES_DIR} ${END_LOG}"
    move_keys_files

    for KEY_INDEX in ${ARRAY_NEW_KEYSTORES[@]}; do
        create_validator_file $KEY_INDEX
    done
fi

# Clean KEYFILES_DIR_TMP files
rm -rf $KEYFILES_DIR_TMP/*

# Run web3signer binary
exec /opt/web3signer/bin/web3signer --key-store-path="$KEYFILES_DIR" --http-listen-port=9003 --http-listen-host=0.0.0.0 --http-host-allowlist=* eth2 --network=prater --slashing-protection-db-url=jdbc:postgresql://postgres:5432/web3signer --slashing-protection-db-username=postgres --slashing-protection-db-password=password