#
# Copyright (c) 2016-2017, Ryan V. Bissell
# All rights reserved.
#
# SPDX-License-Identifier: MIT
# See the enclosed "LICENSE.forge" file for exact license terms.
#

.DEFAULT_GOAL:=all

# INSTRUCTIONS:
#   Copy this file to the base directory of your project, renaming it
#   to 'GNUmakefile'.  Then:
#     - Update the MF_HELPDOC heredoc below
#     - Adjust MF_PROJECT_DIR if needed (unlikely)
#     - After the '------' line below, define your make-forge targets.


# Update this heredoc to describe all the targets that you've defined
define MF_HELPDOC
USAGE:  make <target> [flags]
SUPPORTED TARGETS:
	*   help            -- this message
	*   clean           -- erase results of previous build(s)
	*   static          -- build libfib.$(mflib)
	*   shared          -- build libfib.$(mfdll)
	*   fibgen          -- build fibgen$(mfexe)
	*   all (default)   -- static, shared, and fibgen
SUPPORTED FLAGS:
All of the usual (CPPFLAGS, CXXFLAGS, etc.) plus:
	*   DEBUG=1         -- generate debug information for <target>
	*   VERBOSE=1       -- verbose make-forge output
	*   TEST=1          -- dry-run of recipes for <target>
endef


# tell make-forge where the project's base directory is.
# setting it to CURDIR is probably the right thing to do.
MF_PROJECT_DIR:=$(CURDIR)

# load & initialize make-forge
include $(MF_PROJECT_DIR)/../../make-forge


# --------------------------------------------------------------------


# Update the line below to indicate targets that are included with 'all'
all: static shared fibgen


# At this point you can declare your make-forge targets, as needed.
# Note that if your project can be compiled both as a standalone
# application, and also as a library for use by other make-forge
# projects, it is customary to place the library targets in a separate
# 'GNUmakefile.mf' file, and have this file include that one. (See
# the 'fibgen' sample for an example.)



# load up this project's make-forge fragment, which
# defines how to build the libfib library
include $(CURDIR)/GNUmakefile.MF


# describe how to build fibgen[.exe]
$(eval $(call mf_declare_target,fibgen))
    $(eval $(call mf_static_dependencies,static))
    override CPPFLAGS+=-I$(MF_PROJECT_DIR)/inc
    $(eval $(call mf_add_sources,c,$(MF_PROJECT_DIR)/src,fibgen.c))
    $(eval $(call mf_add_sources,c,$(MF_PROJECT_DIR)/src,main.c))
$(eval $(call mf_build_executable,fibgen))



