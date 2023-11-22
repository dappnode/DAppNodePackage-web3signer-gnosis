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
FROM postgres:14.1-bullseye

ARG UPSTREAM_VERSION

ENV POSTGRES_PASSWORD=gnosis \
    PGPASSWORD=gnosis \
    POSTGRES_USER=postgres \ 
    POSTGRES_DB=web3signer-gnosis \
    INITDB_DIR=/docker-entrypoint-initdb.d/

RUN apt update && apt install -y rename

COPY --from=postgres-migrations /usr/src/app/web3signer-${UPSTREAM_VERSION}/slashing-protection/src/main/resources/migrations/postgresql/* ${INITDB_DIR}

RUN rename 's/(\d+)(?=.*\.)/sprintf("%03d",$1)/eg' /docker-entrypoint-initdb.d/*

CMD ["postgres"]