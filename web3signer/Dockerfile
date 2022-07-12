ARG UPSTREAM_VERSION

###############
# Prune image #
###############
# golang alpine 1.17
FROM golang:1.17-alpine as importer
WORKDIR /usr/src/app
# Needed to create binary to be executed in debian. See https://pkg.go.dev/cmd/cgo
ENV CGO_ENABLED=0
RUN apk update && apk add git && git clone https://github.com/dappnode/web3signer-import-one-by-one.git && \
  go build -o import-one-by-one ./web3signer-import-one-by-one/import_one_by_one.go

################
# Runner image #
################

FROM consensys/web3signer:$UPSTREAM_VERSION
USER root
RUN apt update && apt install cron inotify-tools jq ca-certificates unzip --yes

COPY /security /security
COPY manual-migration.sh /usr/bin/manual-migration.sh
COPY delete-keys.sh /usr/bin/delete-keys.sh
COPY reload-keys.sh /usr/bin/reload-keys.sh
COPY reload-keys-cron /etc/cron.d/
COPY entrypoint.sh /usr/bin/entrypoint.sh

# Copy import one-by-one
COPY --from=importer /usr/src/app/import-one-by-one /usr/bin

# Apply cron job
RUN crontab /etc/cron.d/reload-keys-cron
#USER web3signer
EXPOSE 9000
ENTRYPOINT /bin/bash /usr/bin/entrypoint.sh