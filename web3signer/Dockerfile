ARG UPSTREAM_VERSION

##############
# WEB3SIGNER #
##############

FROM consensys/web3signer:$UPSTREAM_VERSION
USER root
RUN apt update && apt install inotify-tools jq ca-certificates --yes
COPY /security /security
COPY reload-keys.sh /usr/bin/reload-keys.sh
COPY entrypoint.sh /usr/bin/entrypoint.sh
EXPOSE 9000
ENTRYPOINT /bin/bash /usr/bin/entrypoint.sh