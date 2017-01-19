#
# Copyright (c) 2017, Ryan V. Bissell
# All rights reserved.
#
# SPDX-License-Identifier: MIT
# See the enclosed "LICENSE.forge" file for exact license terms.
#

.DEFAULT_GOAL:=static

define MF_HELPDOC
USAGE:  make <target> [flags]
SUPPORTED TARGETS:
	*   help              -- this message
	*   clean             -- erase cx-specific contents of CXOUT
	*   static (default)  -- build libfib.$(mflib)
	*   shared            -- build libfib.$(mfdll)
	*   fibgen            -- build fibgen$(mfexe)
SUPPORTED FLAGS:
All of the usual (CPPFLAGS, CXXFLAGS, etc.) plus:
	*   DEBUG=1           -- generate debug information for <target>
	*   VERBOSE=1         -- verbose make-forge output
	*   TEST=1            -- dry-run of recipes for <target>
endef


# tell make-forge where the project's base directory is
MF_PROJECT_DIR:=$(CURDIR)

# this tells make-forge where all build output should be written
# TODO, should default to $(MF_PROJECT_DIR)/out if not defined
MFOUT:=$(CURDIR)/out

# load & initialize make-forge
include $(MF_PROJECT_DIR)/../../make-forge

# load up this project's make-forge fragment, which
# defines how to build the libfib library
include $(CURDIR)/GNUmakefile.forge


# describe how to build fibgen[.exe]
$(eval $(call mf_declare_target,fibgen))
    $(eval $(call mf_static_dependencies,static))
    override CPPFLAGS+=-I$(MF_PROJECT_DIR)/inc
    $(eval $(call mf_add_sources,c++,$(MF_PROJECT_DIR)/src,fibgen.c))
    $(eval $(call mf_add_sources,c++,$(MF_PROJECT_DIR)/src,main.c))
$(eval $(call mf_build_executable,fibgen))


