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

##########
# FLYWAY #
##########
FROM flyway/flyway:10.0.1-alpine
ARG UPSTREAM_VERSION

RUN apk update && apk --no-cache add postgresql-client
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh && rm -rf /flyway/sql/*
COPY --from=postgres-migrations /usr/src/app/web3signer-${UPSTREAM_VERSION}/slashing-protection/src/main/resources/migrations/postgresql/* /flyway/sql/
ENTRYPOINT ["entrypoint.sh"]
