#
# Copyright (c) 2016, Ryan V. Bissell
# All rights reserved.
#
# SPDX-License-Identifier: MIT
# See the enclosed "LICENSE" file for exact license terms.
#

ifndef MF_INCLUDE_GUARD
override MF_INCLUDE_GUARD:=1

override mfdir:=$(dir $(lastword $(MAKEFILE_LIST)))
override mf_myname:=$(notdir $(lastword $(MAKEFILE_LIST)))
ifndef MF_PROJECT_DIR
$(error You must define 'MF_PROJECT_DIR' before including $(mf_myname))
endif

# superior makefiles need to be able to override MFOUT
MFOUT:=$(MF_PROJECT_DIR)/out
include $(mfdir)/_forge-common.incl


# this will be the default make-target unless you set .DEFAULT_GOAL
.PHONY: help
help:
	$(_mf_display_help)


# .ONESHELL is needed for MF_HELPDOC, but impacts all recipes
.ONESHELL:
ifndef MF_HELPDOC
$(error You must define MF_HELPDOC before including $(mf_myname))
endif
define _mf_display_help =
	@echo ""
	@cat <<- EOF
	$(MF_HELPDOC)
	EOF
	@echo ""
endef

endif  # MF_INCLUDE_GUARD
