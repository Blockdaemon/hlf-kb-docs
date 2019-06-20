.PHONY: all clean artifacts
CHANNEL=mychannel

all: configtx.yaml

artifacts: artifacts/${CHANNEL}.txn artifacts/${CHANNEL}-anchor-peers.txn

%.yaml: templates/%.yaml.in config.env Makefile
	eval $$(sed -e 's/#.*$$//' config.env) ./tools/jinja2-cli.py < $< > $@ || (rm -f $@; false)

${CHANNEL}/msp/admincerts/cert.pem: PeerAdmin/msp/signcerts/cert.pem
	@mkdir -p ${CHANNEL}/msp/cacerts/ ${CHANNEL}/msp/admincerts/
	cp -f PeerAdmin/msp/cacerts/*.pem ${CHANNEL}/msp/cacerts/
	cp -f PeerAdmin/msp/signcerts/cert.pem ${CHANNEL}/msp/admincerts/

artifacts/${CHANNEL}.txn: configtx.yaml ${CHANNEL}/msp/admincerts/cert.pem
	@mkdir -p artifacts
	configtxgen -configPath ${PWD} -profile SingleMSPChannel -outputCreateChannelTx $@ -channelID ${CHANNEL}

artifacts/${CHANNEL}-anchor-peers.txn: configtx.yaml
	@mkdir -p artifacts
	configtxgen -configPath ${PWD} -profile SingleMSPChannel -outputAnchorPeersUpdate $@ -channelID ${CHANNEL} -asOrg PeerOrg

clean:
	rm -rf *.pem PeerAdmin/ configtx.yaml artifacts ./${CHANNEL}/ *.block
