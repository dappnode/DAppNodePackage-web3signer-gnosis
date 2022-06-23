#!/bin/bash

CLIENTS_TO_REMOVE=("$@")

for client in "${CLIENTS_TO_REMOVE[@]}"; do
  case "$client" in
  "prysm")
    CLIENT_API="http://validator.gnosis-beacon-chain-prysm.dappnode:3500"
    TOKEN_FILE="/security/prysm/auth-token"
    CERT_REQUEST=""
    ;;
  "teku")
    CLIENT_API="https://validator.teku-gnosis.dappnode:3500"
    TOKEN_FILE="/security/teku/validator-api-bearer"
    CERT_REQUEST="-k --cert-type P12 --cert /security/teku/cert/teku_client_keystore.p12:dappnode"
    ;;
  "lighthouse")
    CLIENT_API="http://validator.lighthouse-gnosis.dappnode:3500"
    TOKEN_FILE="/security/lighthouse/api-token.txt"
    CERT_REQUEST=""
    ;;
  *)
    echo "client does not exist"
    exit 1
    ;;
  esac

  # Get the token
  if [[ -f ${TOKEN_FILE} ]]; then
    AUTH_TOKEN=$(cat "${TOKEN_FILE}")
    if [[ -z ${AUTH_TOKEN} ]]; then
      echo "token file is empty"
      exit 1
    fi
  else
    echo "token file not found in ${TOKEN_FILE}"
    exit 1
  fi

  # GET response
  get_response=$(curl -s -w "%{http_code}" ${CERT_REQUEST} -X GET -H "Authorization: Bearer ${AUTH_TOKEN}" -H "Content-Type: application/json" "${CLIENT_API}/eth/v1/remotekeys")
  # GET HTTP code
  get_http_code=${get_response: -3}
  # GET content
  get_content=$(echo "${get_response}" | head -c-4)
  if [[ ${get_http_code} == 200 ]]; then
    client_pubkeys=($(echo "${get_content}" | jq -r 'try .data[].pubkey'))
    if ((${#client_pubkeys[@]})); then
      # format: "pubkey1","pubkey2","pubkey3"...
      client_pubkeys_comma_separated=$(echo "\"${client_pubkeys[*]}\"" | sed -r 's/ /\",\"/g')

      # Delete public keys on the client
      echo "deleting pubkeys ${client_pubkeys_comma_separated} on client ${client}"
      delete_request="{\"pubkeys\": [${client_pubkeys_comma_separated}]}"
      curl ${CERT_REQUEST} -X DELETE -H "Authorization: Bearer ${AUTH_TOKEN}" -H "Content-Type: application/json" --data "${delete_request}" "${CLIENT_API}/eth/v1/remotekeys"
    fi
  fi
done
