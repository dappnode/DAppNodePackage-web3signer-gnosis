##############
# MIGRATIONS #
##############
FROM alpine:3.15.10 as postgres-migrations
ARG UPSTREAM_VERSION
WORKDIR /usr/src/app

# Install wget and other dependencies, if necessary
RUN apk --no-cache add wget

# Get migrations from ConsenSys web3signer repository
RUN wget -q https://github.com/ConsenSys/web3signer/archive/refs/tags/${UPSTREAM_VERSION}.tar.gz && \
    tar -xvf ${UPSTREAM_VERSION}.tar.gz && \
    rm ${UPSTREAM_VERSION}.tar.gz

############
# POSTGRES #
############
FROM postgres:14.1-alpine3.15

ARG UPSTREAM_VERSION

ENV POSTGRES_PASSWORD=password \
    PGPASSWORD=password \
    POSTGRES_USER=postgres \ 
    POSTGRES_DB=web3signer \
    INITDB_DIR=/docker-entrypoint-initdb.d/

COPY rename_files.sh /usr/local/bin/rename_files.sh

COPY --from=postgres-migrations /usr/src/app/web3signer-${UPSTREAM_VERSION}/slashing-protection/src/main/resources/migrations/postgresql/* ${INITDB_DIR}

RUN /usr/local/bin/rename_files.sh

USER postgres

CMD ["postgres"]