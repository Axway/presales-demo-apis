## Find file .local.env in directory and above.
include $(shell unset F; S=.local.env; B=$$PWD; while [ -z "$$F" ]; do [ -z "$$B" ] && F="dev/null" || [ -f "$$B/$$S" ] && F="$$B/$$S" || B="$${B%/*}" ; done ; echo $$F)

#####################################################################
### Useful declarations
#####################################################################
export SCOPE := iot

#####################################################################
### Recursion
#####################################################################
# identify every subfolder
SUBDIRS :=  $(wildcard */.)

# a target is created for each subfolder.
# This target re-execute make into the subfolder with same arguments.
.PHONY: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

#####################################################################
### Targets of interrest
#####################################################################
# gen is recursed into subfolders
# Files of interrest should be generated at this step
gen: $(SUBDIRS)

# clean is recursed into subfolders
# Generated files must be removed by this command.
clean: $(SUBDIRS)

# Once 'gen' is done, publish is recursed into subfolders
# Publishes the new version of an api to the gateway
publish: gen $(SUBDIR)
