## Find file .local.env in directory and above.
include $(shell unset F; S=.local.env; B=$$PWD;while [ -z "$$F" ]; do [ -z "$$B" ] && F="/dev/null" || { [ -f "$$B/$$S" ] && F="$$B/$$S" || B="$${B%/*}";} done;echo $$F)

#####################################################################
### See Makefile in parent folder for a description of the possible
### goals of interrest
#####################################################################

#####################################################################
### Technicalities. Any goals called on this directory is cascaded
### to any sulfolder containing a Makefile.
#####################################################################
.PHONY: $(GOALS) $(SUBDIRS)
SUBDIRS := $(patsubst %/Makefile,%,$(wildcard */Makefile))
GOALS := $(or $(MAKECMDGOALS),all)
$(GOALS): $(SUBDIRS) FORCE
$(SUBDIRS): FORCE
	@echo "  - ${@}"
	-@$(MAKE) -C $@ $(MAKECMDGOALS)
FORCE: ;