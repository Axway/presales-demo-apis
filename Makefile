## Why using makefiles?
##  - they are very flexible
##  - nearly every OS has a decent version of Make
##  - can be executed locally (i.e. does not need a "phantom push" to execute a pipeline / workflow / whatever)

## To define local variables like APIM_HOST etc...
## The minus makes the 'include' command not choke on a missing file.
export SHELL := /bin/bash
.ONESHELL:

## Find file .local.env in directory and above.
include .local.env

#####################################################################
### Useful declarations
#####################################################################
### This one should be copied verbatim in your .local.env
export APIM := docker run --rm -e APIM_HOST="${APIM_HOST}" -e APIM_USER="${APIM_USER}" -e APIM_PASS="${APIM_PASS}" -e APIM_PORT="${APIM_PORT}" jmcabrera/apim-cli:1.3.7

# #####################################################################
# ### Targets of interrest.
# ### They are redundant given the technicalities at the bottom of this
# ### file, but we leave them for documentation.
# #####################################################################
# # gen is recursed into subfolders
# # Files of interrest should be generated at this step
# gen: init $(SUBDIRS)
#
# # clean is recursed into subfolders
# # Generated files must be removed by this command.
# clean: init $(SUBDIRS)
#
# # Once 'gen' is done, publish is recursed into subfolders
# # Publishes the new version of an api to the gateway
# publish: init $(SUBDIR)

#####################################################################
### Technicalities. No reason to call these targets directly,
### However, other higher-valued targers might depend on these.
#####################################################################

# Identifies every subfolder having a Makefile
# Most of the goals will be cascaded to these subfolders
.PHONY: $(GOALS) $(SUBDIRS)
SUBDIRS := $(patsubst %/Makefile,%,$(wildcard */Makefile))

GOALS := $(filter-out init probe,$(or $(MAKECMDGOALS),all))
$(GOALS): $(SUBDIRS)

# Anything happening to any subfolder of interrest triggers
# init, which basically installs some NodeJS tooling
$(SUBDIRS): init
	@printf '\n********************\nBuilding $@\n--------------------\n'
	-@$(MAKE) -C $@ $(MAKECMDGOALS)

# Make sure that, if there is no node_modules folder, an npm install is ran.
# That way, e.g. json-merger, on which several other Makefiles downtream depend, is available.
init: node_modules .local.env

probe: init
	$(APIM) api get

node_modules:
	@npm i -y

## Provides a sensible default for .local.env file.
.local.env:
	@printf '\
	### Some sensitive defaults, you can change them here \n\
	### or export a shell variable with the same name \n\
	### These variables are _not_ used in the CI/CD \n\
	### They are _only_ useful to make things locally \n\
	### To change CI/CD values, change github''s secrets \n\
	### Do __NOT__ commit this file \n\
	### What to start afresh? Delete this file and "make init" at root. \n\
	export APIM_HOST?=localhost \n\
	export APIM_PORT?=8075 \n\
	export APIM_USER?=apiadmin \n\
	export APIM_PASS?=changeme \n\
	export APIM:=docker run --rm -e APIM_HOST="$${APIM_HOST}" -e APIM_USER="$${APIM_USER}" -e APIM_PASS="$${APIM_PASS}" -e APIM_PORT="$${APIM_PORT}" -v $$$$(pwd):$$$$(pwd) -w $$$$(pwd) jmcabrera/apim-cli:1.3.7' >> .local.env
	
