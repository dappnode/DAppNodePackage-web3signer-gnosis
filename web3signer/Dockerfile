ARG UPSTREAM_VERSION

FROM consensys/web3signer:$UPSTREAM_VERSION
USER root
RUN apt update && apt install cron inotify-tools jq ca-certificates --yes

COPY /security /security
COPY reload-keys.sh /usr/bin/reload-keys.sh
COPY entrypoint.sh /usr/bin/entrypoint.sh
COPY reload-keys-cron /etc/cron.d/

ENV JAVA_HOME=/opt/java/openjdk/bin/java

# Apply cron job
RUN crontab /etc/cron.d/reload-keys-cron
#USER web3signer
EXPOSE 9000
ENTRYPOINT /bin/bash /usr/bin/entrypoint.sh