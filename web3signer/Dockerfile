ARG UPSTREAM_VERSION

##############
# WEB3SIGNER #
##############

FROM consensys/web3signer:$UPSTREAM_VERSION
RUN apt update && apt install cron jq ca-certificates --yes
COPY /security /security
COPY entrypoint.sh /usr/bin/entrypoint.sh
EXPOSE 9000
ENTRYPOINT /bin/bash /usr/bin/entrypoint.sh