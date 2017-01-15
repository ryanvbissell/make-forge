#
# Copyright (c) 2016-2017, Ryan V. Bissell
# All rights reserved.
#
# SPDX-License-Identifier: MIT
# See the enclosed "LICENSE" file for exact license terms.
#
override _myname:=$(notdir $(lastword $(MAKEFILE_LIST)))
override _mydir:=$(dir $(lastword $(MAKEFILE_LIST)))

override TFDIR:=$(dir $(realpath $(_myname)))
override MF_TESTROOT:=$(dir $(abspath $(_myname)))

ifeq ("$(wildcard $(TFDIR)/test-forge.mk)","")
    $(info $(shell echo "\033[0;31mCannot find file 'test-forge.mk'"))
    $(info $(shell echo "Did you forget to use 'make TFDIR=<path>', when in a submodule?\033[0m"))
    $(error Aborting)
endif

include $(TFDIR)/test-forge.mk


tf_subdirs:=$(sort $(wildcard */))
tf_subdirs:=$(patsubst %/,%,$(tf_subdirs))
$(info === Importing tests ...)
$(eval $(call tf_include_testdirs,$(tf_subdirs)))

_all: $(tf_topdeps)


