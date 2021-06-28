## Find file .local.env in directory and above.
include $(shell unset F; S=.local.env; B=$$PWD; while [ -z "$$F" ]; do [ -z "$$B" ] && F="dev/null" || [ -f "$$B/$$S" ] && F="$$B/$$S" || B="$${B%/*}" ; done ; echo $$F)

API_CFG ?= gen.api-config.json
API_TPL ?= api-config-tpl.json

$(API_CFG): $(API_TPL)
	npx json-merger $< -p | jq . > $@

gen: $(API_CFG)

clean:
	rm -rf $(API_CFG)

publish: $(API_CFG)
	${APIM} api import -c $(API_CFG)

.PHONY: gen clean publish