ARG UPSTREAM_VERSION

FROM consensys/web3signer:$UPSTREAM_VERSION
USER root
RUN apt update && apt install cron inotify-tools jq ca-certificates --yes

COPY /security /security
COPY delete-keys.sh /usr/bin/delete-keys.sh
COPY reload-keys.sh /usr/bin/reload-keys.sh
COPY reload-keys-cron /etc/cron.d/
COPY entrypoint.sh /usr/bin/entrypoint.sh

# Apply cron job
RUN crontab /etc/cron.d/reload-keys-cron
#USER web3signer
EXPOSE 9000
ENTRYPOINT /bin/bash /usr/bin/entrypoint.sh