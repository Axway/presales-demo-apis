## Why using makefiles?
##  - they are very flexible
##  - nearly every OS has a decent version of Make
##  - can be executed locally (i.e. does not need a "phantom push" to execute a pipeline / workflow / whatever)

## To define local variables like APIM_HOST etc...
## The minus makes the 'include' command not choke on a missing file.
export SHELL := /bin/bash

## Find file .local.env in directory and above.
include $(shell unset F; S=.local.env; B=$$PWD; while [ -z "$$F" ]; do [ -z "$$B" ] && F="dev/null" || [ -f "$$B/$$S" ] && F="$$B/$$S" || B="$${B%/*}" ; done ; echo $$F)

#####################################################################
### Useful declarations
#####################################################################
export APIM := @docker run --rm -e APIM_HOST="${APIM_HOST}" -e APIM_USER="${APIM_USER}" -e APIM_PASS="${APIM_PASS}" -e APIM_PORT="${APIM_PORT}" jmcabrera/apim-cli:1.3.7

#####################################################################
### Recursion
#####################################################################
# identify every subfolder
SUBDIRS := couponing health_authority insurtech iot

# a target is created for each subfolder.
# This target re-execute make into the subfolder with same arguments.
.PHONY: gen clean publish init $(SUBDIRS)
$(SUBDIRS): init
	$(MAKE) -C $@ $(MAKECMDGOALS)

#####################################################################
### Targets of interrest
#####################################################################
# gen is recursed into subfolders
# Files of interrest should be generated at this step
gen: init $(SUBDIRS)

# clean is recursed into subfolders
# Generated files must be removed by this command.
clean: init $(SUBDIRS)

# Once 'gen' is done, publish is recursed into subfolders
# Publishes the new version of an api to the gateway
publish: init gen $(SUBDIR)

# Make sure that, if there is no node_modules folder, an npm install is issued.
# That way, json-merger, on which several other Makefiles downtream depend, is available.
init: node_modules

node_modules:
	npm i -y