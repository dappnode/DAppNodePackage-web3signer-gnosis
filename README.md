<!-- :female_detective: Looking for a new champion -->

# DAppNode package _Web3signer_

<!--DAppNode package logo (could be added with an hyperlink to a youtube video): -->

![](node-avatar.png)

<!--Brief introduction about the source project (official project definition is an option): -->

A validator client contributes to the consensus of the Eth2 blockchain by signing proposals and attestations of blocks, using a BLS private key which must be available to this client at all times.

The BLS remote signer API is designed to be consumed by validator clients, looking for a more secure avenue to store their BLS12-381 private key(s), enabling them to run in more permissive and scalable environments.

More information about the EIP can be found at [the official website](https://eips.ethereum.org/EIPS/eip-3030)

### Why _Web3signer_ ?

<!--What can you do with this package?: -->

Client diversity is a key path in DAppNode, you will be able to use different clients and do not deposit all the trust on just one of them. It can work as a load balancer, keeping your validators always validating

### Requirements

Rquirements to run DAppNode package for Werb3signer

<!--Requirements to run the dappnode package in a list: -->

- **Validator**: set up your validator at [https://prater.launchpad.ethereum.org/](https://docs.gnosischain.com/validator-info/validator-deposits)
- **Ethereum1 client**: you should have installed and synced an Eth1 client from Gosis chain such as nethermind
- **Ethereum2 client**: you should have installed and synced an Eth2 client from Gnosis chain such as Prysm-gnosis

### Manteinance

<!--Table with champion/s mantainers, versions and update status -->
<!--UPDATED: :x: OR :heavy_check_mark: -->

|      Updated       |   Champion/s   |
| :----------------: | :------------: |
| :heavy_check_mark: | @pablomendez95 |

### Development

Build the development binary of the web3signer. Also uses the latest postgresql scripts defined at https://github.com/ConsenSys/web3signer/tree/master/slashing-protection/src/main/resources/migrations/postgresql

```
npx @dappnode/dappnodesdk build --compose_file_name=docker-compose.dev.yml
```
