ARG UPSTREAM_VERSION

###########
# BUILDER #
###########

# TEMPORARY!: Until keymanager is released in the official web3signer docker image

FROM openjdk:11 as builder
WORKDIR /usr/src/app
RUN apt update && apt install git -y && git clone https://github.com/joaquim-verges/web3signer.git 
WORKDIR /usr/src/app/web3signer 
RUN git fetch origin && git checkout -b keymanager origin/keymanager && ./gradlew clean assemble && tar -xzf ./build/distributions/web3signer-develop.tar.gz

##############
# WEB3SIGNER #
##############
FROM consensys/web3signer:$UPSTREAM_VERSION

# Copy web3signer keymanager binary
COPY --from=builder /usr/src/app/web3signer/web3signer-develop /opt/web3signer

EXPOSE 9003

COPY entrypoint.sh /usr/bin/entrypoint.sh
ENTRYPOINT /bin/bash /usr/bin/entrypoint.sh