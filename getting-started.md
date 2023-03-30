## Welcome to your web3signer:

- This is the entrypoint for handling your validator keystores
- Web3signer takes care for signing requests of your validator
- Web3signer supports client diversity, working with different clients such as [Lighthouse-gnosis](http://my.dappnode/#/installer/lighthouse-gnosis.dnp.dappnode.eth) and [Teku-gnosis](http://my.dappnode/#/installer/teku-gnosis.dnp.dappnode.eth)
- The Flyway service takes care of importing the previous version's slashing protection database when an update is installed, so it's meant to run only once per update, and it is normal to see that the Flyway service is stopped
