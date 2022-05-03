FROM openjdk:11
ARG UPSTREAM_VERSION
WORKDIR /opt/web3signer
RUN apt update && apt install inotify-tools jq --yes && \
  curl https://artifacts.consensys.net/public/web3signer/raw/names/web3signer.zip/versions/${UPSTREAM_VERSION}/web3signer-${UPSTREAM_VERSION}.zip --output web3signer.zip && \
  unzip web3signer.zip && \
  mv web3signer-${UPSTREAM_VERSION}/* /opt/web3signer && \
  rm -rf web3signer.zip web3signer-${UPSTREAM_VERSION}

ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8
ENV JAVA_VERSION=jdk-11.0.11+9
ENV JAVA_HOME=/opt/java/openjdk PATH=/opt/java/openjdk/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

COPY /security /security
COPY reload-keys.sh /usr/bin/reload-keys.sh
COPY entrypoint.sh /usr/bin/entrypoint.sh

EXPOSE 9000
ENTRYPOINT /bin/bash /usr/bin/entrypoint.sh