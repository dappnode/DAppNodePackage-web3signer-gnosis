ARG UPSTREAM_VERSION

##############
# WEB3SIGNER #
##############

FROM consensys/web3signer:$UPSTREAM_VERSION
COPY entrypoint.sh /usr/bin/entrypoint.sh
EXPOSE 9000
ENTRYPOINT /bin/bash /usr/bin/entrypoint.sh