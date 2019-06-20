# Hyperledger Fabric Knowledge Base

## Articles

* [Getting the Hyperledger Fabric tools](Tools.md)
* [Bootstrapping the initial PeerOrg admin](Bootstrap.md)
* [Creating a channel](Channel.md)
* [Installing and executing chaincode](Chaincode.md)

## `configtx.yaml` creation wizard requirements

### MacOS

```bash
brew install python3
pip3 install jinja2
```

### Ubuntu/Debian

```bash
sudo apt install python3-jinja2
```

## Prefab workflow

Instead of following all the documents above, you can use the premade utilities here. You will still need to [get the Hyperledger Fabric tools](Tools.md) before starting this process.

```bash
cp config.env-example config.env
```

Edit `config.env`

```bash
make
./bootstrap
```

Note password

```
PASSWORD="password-from-above" ./enroll.sh
./channel.sh
```
