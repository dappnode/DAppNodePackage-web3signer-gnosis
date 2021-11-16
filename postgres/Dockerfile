FROM postgres:9.6.24

ADD https://raw.githubusercontent.com/ConsenSys/web3signer/master/slashing-protection/src/main/resources/migrations/postgresql/V1__initial.sql /docker-entrypoint-initdb.d/
ADD https://raw.githubusercontent.com/ConsenSys/web3signer/master/slashing-protection/src/main/resources/migrations/postgresql/V2__removeUniqueConstraints.sql /docker-entrypoint-initdb.d/
ADD https://raw.githubusercontent.com/ConsenSys/web3signer/master/slashing-protection/src/main/resources/migrations/postgresql/V3__addLowWatermark.sql /docker-entrypoint-initdb.d/
ADD https://raw.githubusercontent.com/ConsenSys/web3signer/master/slashing-protection/src/main/resources/migrations/postgresql/V4__addGenesisValidatorsRoot.sql /docker-entrypoint-initdb.d/
ADD https://raw.githubusercontent.com/ConsenSys/web3signer/master/slashing-protection/src/main/resources/migrations/postgresql/V5__xnor_source_target_low_watermark.sql /docker-entrypoint-initdb.d/
ADD https://raw.githubusercontent.com/ConsenSys/web3signer/master/slashing-protection/src/main/resources/migrations/postgresql/V6__signed_data_indexes.sql /docker-entrypoint-initdb.d/
ADD https://raw.githubusercontent.com/ConsenSys/web3signer/master/slashing-protection/src/main/resources/migrations/postgresql/V7__add_db_version.sql /docker-entrypoint-initdb.d/
ADD https://raw.githubusercontent.com/ConsenSys/web3signer/master/slashing-protection/src/main/resources/migrations/postgresql/V8__signed_data_unique_constraints.sql /docker-entrypoint-initdb.d/
ADD https://raw.githubusercontent.com/ConsenSys/web3signer/master/slashing-protection/src/main/resources/migrations/postgresql/V9__upsert_validators.sql /docker-entrypoint-initdb.d/

RUN chmod 777 /docker-entrypoint-initdb.d/V1__initial.sql
RUN chmod 777 /docker-entrypoint-initdb.d/V2__removeUniqueConstraints.sql
RUN chmod 777 /docker-entrypoint-initdb.d/V3__addLowWatermark.sql
RUN chmod 777 /docker-entrypoint-initdb.d/V4__addGenesisValidatorsRoot.sql
RUN chmod 777 /docker-entrypoint-initdb.d/V5__xnor_source_target_low_watermark.sql
RUN chmod 777 /docker-entrypoint-initdb.d/V6__signed_data_indexes.sql
RUN chmod 777 /docker-entrypoint-initdb.d/V7__add_db_version.sql
RUN chmod 777 /docker-entrypoint-initdb.d/V8__signed_data_unique_constraints.sql
RUN chmod 777 /docker-entrypoint-initdb.d/V9__upsert_validators.sql

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["postgres"]
