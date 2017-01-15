#
# Copyright (c) 2016-2017, Ryan V. Bissell
# All rights reserved.
#
# SPDX-License-Identifier: MIT
# See the enclosed "LICENSE.forge" file for exact license terms.
#

ifndef __mf_include_guard
override __mf_include_guard:=1

override _mfname:=$(notdir $(lastword $(MAKEFILE_LIST)))
ifndef MF_PROJECT_DIR
$(error You must define 'MF_PROJECT_DIR' before including $(_mfname))
endif

# superior makefiles need to be able to override MFOUT
MFOUT:=$(MF_PROJECT_DIR)/out

override _mfdir:=$(dir $(lastword $(MAKEFILE_LIST)))
override _mfdir:=$(_mfdir:%/=%)
include $(_mfdir)/_forge-common.incl


# this will be the default make-target unless you set .DEFAULT_GOAL
.PHONY: help
help:
	$(__mf_display_help)


# .ONESHELL is needed for MF_HELPDOC, but impacts all recipes
.ONESHELL:
ifndef MF_HELPDOC
$(error You must define MF_HELPDOC before including $(_mfname))
endif
define __mf_display_help =
	@echo ""
	@cat <<- EOF
	$(MF_HELPDOC)
	EOF
	@echo ""
endef


# TODO, this was moved here from _forge-common, so that 'clean'
# would not appear as a target for test-forge.  I would like for
# 'clean' to be available for test-forge, but presently there is a
# problem with cleaning the individual tests' .log files, that must
# be addressed first.
.SECONDEXPANSION:
clean:: $$(mf_clean_targets)
	@([ -e $(MFOUT) ] && echo "+++ [$(notdir $(MFOUT))] Removing...") || true
	@([ -e $(MFOUT) ] && $(test) rmdir --ignore-fail-on-non-empty $(MFOUT)) || true


endif  # __mf_include_guard
