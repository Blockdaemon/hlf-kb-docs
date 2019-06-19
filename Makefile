all: configtx.yaml

%.yaml: templates/%.yaml.in config.env Makefile
	eval $$(sed -e 's/#.*$$//' config.env) ./tools/jinja2-cli.py < $< > $@ || (rm -f $@; false)
