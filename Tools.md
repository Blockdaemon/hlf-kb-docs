# Getting the Hyperledger Fabric Tools

*For MacOS use `HLF_ARCH=darwin-amd64`*

## `fabric-ca-client`

```shell
HLF_ARCH=linux-amd64
HLF_VERSION=1.4.1
curl https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric-ca/hyperledger-fabric-ca/${HLF_ARCH}-${HLF_VERSION}/hyperledger-fabric-ca-${HLF_ARCH}-${HLF_VERSION}.tar.gz \
 | sudo tar xz -C /usr/local
```

## `configtxgen`, `peer`, etc.

```shell
HLF_ARCH=linux-amd64
HLF_VERSION=1.4.1
curl https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric/hyperledger-fabric/${HLF_ARCH}-${HLF_VERSION}/hyperledger-fabric-${HLF_ARCH}-${HLF_VERSION}.tar.gz \
 | sudo tar xz -C /usr/local
```
