#
# Copyright (c) 2016, Ryan V. Bissell
# All rights reserved.
#
# SPDX-License-Identifier: MIT
# See the enclosed "LICENSE" file for exact license terms.
#
override myfile:=$(lastword $(MAKEFILE_LIST))
override mydir:=$(dir $(MAKEFILE_LIST))

override TFDIR:=$(dir $(realpath $(myfile)))
override CXF_TESTROOT:=$(dir $(abspath $(myfile)))


include $(TFDIR)/tf-initialize.mk


tf_subdirs:=$(sort $(wildcard */))
tf_subdirs:=$(patsubst %/,%,$(tf_subdirs))
$(info === Importing tests ...)
$(eval $(call tf_include_testdirs,$(tf_subdirs)))

_all: $(tf_topdeps)


