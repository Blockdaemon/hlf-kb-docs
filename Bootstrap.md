# Bootstrapping the initial PeerOrg admin user

***IMPORTANT!***

*Your new Hyperledger Fabric Network will not be up and running until you create an initial PeerOrg admin user!*

## Prerequisites

* [Download and install the hyperledger fabric tools](Tools.md)

## Fetch the Blockdaemon HLF TLSCA public certificate

*In these examples, `<NetworkID>` is the ID of the network as shown in the Network connect page. Omit the `<>`'s, e.g. `NETWORK_ID="abcdefgh"`.*

```shell
NETWORK_ID="<NetworkID>"

curl -sk https://ca-server.${NETWORK_ID}.bdnodes.net:7054 \
  | jq -r ".result.CAChain" \
  | base64 -d > tlcsa-${NETWORK_ID}.pem
```

For MacOS, `base64 -D` may be required

## Enroll the CA admin and initial PeerOrg admin

### Enroll the CA admin

*In this example, `<ca_admin_user>` and `<ca_admin_pass>` are the credentials shown on the Network connect page. Omit the `<>`'s, e.g. `CA_USER="admin"`.*

```shell

NETWORK_ID="<NetworkID>"
CA_USER="<ca_admin_user>"
CA_PASS="<ca_admin_pass>"

export FABRIC_CA_CLIENT_TLS_CERTFILES="${PWD}/tlsca-${NETWORK_ID}.pem"
export FABRIC_CA_CLIENT_CANAME="ca-peer-org"
fabric-ca-client enroll \
  -u "https://${CA_USER}:${CA_PASS}@ca-server.${NETWORK_ID}.bdnodes.net:7054"
```

### Register and enroll the PeerOrg admin

***TBD - Not sure if `FABRIC_CA_CLIENT_` vars are needed for `fabric-ca-client register`, they might be stored in the local admin MSP during the above enroll"?***

***IMPORTANT!***

*This `fabric-ca-client register/enroll` step can only be done once! Once you have registered the PeerOrg Admin user, you cannot reregister it again unless you remove the existing one first with `fabric-ca-client identity remove`. If a new PeerOrg admin is `enrolled`, any existing peers or orderers that identify the original identity as an admin cannot be updated, but only new peers will indentify the new identity as an admin!*

Register the new PeerOrg admin. Its password will be printed on stdout:

```shell
NETWORK_ID="<NetworkID>"

export FABRIC_CA_CLIENT_TLS_CERTFILES="${PWD}/tlsca-${NETWORK_ID}.pem"
export FABRIC_CA_CLIENT_CANAME="ca-peer-org"
fabric-ca-client register \
  -u "https://ca-server.${NETWORK_ID}.bdnodes.net:7054" \
  --id.type=user \
  --id.name Admin@${NETWORK_ID}-PeerOrg
```

You should see:

```shell
Password: abcdefgh
```

Enroll the initial PeerOrg admin, and generate an MSP directory structure in PeerAdmin/msp:

*In this example, `<RegisterPassword>` is the password printed on stdout from the command above. Omit the `<>`'s, e.g. `PASSWORD="abcdefgh"`*

```shell
NETWORK_ID="<NetworkID>"
PASSWORD="<RegisterPassword>"

mkdir -p PeerAdmin

export FABRIC_CA_CLIENT_TLS_CERTFILES="${PWD}/tlsca-${NETWORK_ID}.pem"
export FABRIC_CA_CLIENT_CANAME="ca-peer-org"
fabric-ca-client enroll \
  -u "https://Admin@${NETWORK_ID}-PeerOrg:${PASSWORD}@ca-server.${NETWORK_ID}.bdnodes.net:7054" \
  -H PeerAdmin --csr_names="O=${NETWORK_ID}-PeerOrg"
```

***IMPORTANT!***

*Make sure to keep the `PeerAdmin/msp/keystore` directory safe! Once you enroll the initial PeerOrg admin, these credentials will be ***automatically*** used to generate the system channel genesis block on the orderer, and be granted admin privileges on all the peers in this network. If you lose the credentials for this user, you will no longer be able to create new channels, nor will any peers be able to join any existing channels.*
