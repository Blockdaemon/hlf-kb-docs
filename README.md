# Hyperledger Fabric Knowledge Base

## Articles

* [Getting the Hyperledger Fabric tools](Tools.md)
* [Bootstrapping the initial PeerOrg admin](Bootstrap.md)
* [Creating a channel](Channel.md)
* [Installing and executing chaincode](Chaincode.md)

## Prerequisites

### MacOS

```bash
brew install python3
pip3 install jinja2
```

### Ubuntu/Debian

```bash
sudo apt install python3-jinja2
```

## QUICKSTART

Instead of following all the documents above, you can use the premade quickstart utilities here. You will still need to [get the Hyperledger Fabric tools](Tools.md) before starting this process.

```bash
cp config.env-example config.env
```

Configure `config.env`

Set `NETWORK_ID` to your `<NetworkID>`, and `ANCHOR_PEERS` to a quote enclosed, space separated list of at least two `<NodeID>`s (see [Creating a channel](Channel.md) for details).

```bash
make
./bootstrap.sh
```

Note given password

```
PASSWORD="password-from-above" ./enroll.sh
./channel.sh
```
