#
# Copyright (c) 2016, Ryan V. Bissell
# All rights reserved.
#
# SPDX-License-Identifier: MIT
# See the enclosed "LICENSE" file for exact license terms.
#

ifndef CXF_COMMON_INCLUDE_GUARD
override CXF_COMMON_INCLUDE_GUARD:=1

cxf_myname:=$(notdir $(lastword $(MAKEFILE_LIST)))
ifndef CXFOUT
$(error You must define 'CXFOUT' before including $(cxf_myname))
endif
$(CXFOUT):
	@$(test) mkdir -p $(CXFOUT)


.PHONY: clean


# .d files are precious because they serve to speed up subsequent builds.
# .i files are precious because the user specifically asked for them.
.PRECIOUS: $(CXFOUT)/%.d $(CXFOUT)/%.i



# enable paralellism based on number of available processors
# I believe this is the most portable solution (nearly POSIX)
cxf_numprocs=$(shell getconf _NPROCESSORS_ONLN)
override MAKEFLAGS+= --jobs=${cxf_numprocs}

# group parallel output on a per-target basis,
# and squelch unhelpful output from Make
override MAKEFLAGS+= --output-sync=target
override MAKEFLAGS+= --no-print-directory



# TODO: these should be specific to the host OS
override CXFOBJ:=o
override CXFLIB:=a
override CXFEXE:=


# TODO: some of these may be specific to the host OS
ifdef TEST
    override test:=echo
    override test2:=>/dev/null $(test)
    override pipe:=\|
    override redir:=\>
    override indir:=\<
    override append:=\>\>
    ifeq ($(TEST),2)
        override test2:=$(test)
    endif
else
    override test:=
    override test2:=
    override pipe:=|
    override redir:=>
    override indir:=<
    override append:=>>
endif

override echo:=echo
ifdef CXF_QUIET_BUILDS
    override echo:=>/dev/null echo
endif


define cxf_initialize =
    $(eval override CXF_LDFLAGS:=$(LDFLAGS))
    $(eval override CXF_CPPFLAGS:=$(CPPFLAGS))
    $(eval override CXF_CXXFLAGS:=$(CXXFLAGS))
endef


define cxf_declare_target =
    $(eval override cxf_target:=$(1))
    $(eval override cxf_testout:=$(CXFOUT)/$(cxf_target))
    $(eval override undefine cxf_srcfiles)
    $(eval override undefine cxf_objfiles)
    $(eval override undefine cxf_depfiles)
    $(eval override undefine cxf_libfiles)
    $(eval override undefine cxf_linkfiles)
    $(eval override undefine cxf_deptargets)
endef

define cxf_reset_target =
    $(eval $(call cxf_initialize))
    $(eval $(call cxf_declare_target,$(1)))
endef


define _cxf_compile_c++ =
	@$(echo) "+++ [$$(notdir $(cxf_target))] $$(notdir $$<)"
	@$(test) $(CXX) $(CXF_CPPFLAGS) $(CXF_CXXFLAGS) -c $$< -o $$@
endef


# this will generate source/header dependency info
#    sed:      use FQPN for target
# additionally, the following ensures that the build still succeeds
# if source files get renamed while .d files exist:
#    echo:     add blank line
#    sed:      strip the target (up-to and including colon)
#    sed:      remove any continuation backslash
#    fmt -1:   list 'words' (files) one per line
#    sed:      strip leading spaces
#    sed:      add trailing colons (and blank lines)
#    sed:      remove lines containing only a colon
define _cxf_gen_dependencies =
	@$(test2) $(CXX) -MM $(CXF_CPPFLAGS) $(CXF_CXXFLAGS) $$< $(redir)$(cxf_testout)/$(1).d
	@$(test2) mv -f $(cxf_testout)/$(1).d $(cxf_testout)/$(1).d.tmp
	@$(test2) sed -e 's|.*:|$(cxf_testout)/$(1).o:|' $(indir)$(cxf_testout)/$(1).d.tmp $(redir)$(cxf_testout)/$(1).d
	@$(test2) echo "" $(append)$(cxf_testout)/$(1).d
	@$(test2) sed -e 's/.*://' \
	             -e 's/\\$$$$//' $(indir)$(cxf_testout)/$(1).d.tmp $(pipe) \
	 $(test2) fmt -1 $(pipe) \
	 $(test2) sed -e 's/^ *//' \
	             -e 's/$$$$/:\n/' \
	             -e 's/^:.*$$$$/\n/' $(append)$(cxf_testout)/$(1).d
	@$(test2) $(RM) $(cxf_testout)/$(1).d.tmp
endef


define _cxf_gen_static_pattern_rule
    $(1): $(cxf_testout)/%.$(CXFOBJ): $(2)/%$(3) | $(cxf_testout)
	@$(call _cxf_compile_c++)
	@$(call _cxf_gen_dependencies,$$*)
endef


define cxf_add_sources =
    $(eval override _src:=$(wildcard $(1)/$(2)))
    $(eval override _ext:=$(suffix $(2)))
    $(eval override _obj:=$(subst $(_ext),.$(CXFOBJ),$(_src)))
    $(eval override _obj:=$(subst $(1),$(cxf_testout),$(_obj)))
    $(eval override cxf_srcfiles+= $(_src))
    $(eval override cxf_objfiles+= $(_obj))
    $(eval $(call _cxf_gen_static_pattern_rule,$(_obj),$(1),$(_ext)))
    $(eval undefine _src)
    $(eval undefine _ext)
    $(eval undefine _obj)
endef


define cxf_lib_dependency =
    $(eval override _lib:=$(cxf_$(1)_lib))
    $(eval override cxf_deptargets+= $(1))
    $(eval override cxf_linkfiles+= $(_lib))
    $(eval undefine _lib)
endef


define _cxf_import_depfiles =
    $(eval override cxf_depfiles:=$(cxf_objfiles:.$(CXFOBJ)=.d))
    -include $(cxf_depfiles)
endef


define cxf_build_static_library =
    $(eval $(_cxf_import_depfiles))
    $(eval override cxf_$(cxf_target)_lib:=$(cxf_testout)/$(1).a)

    $(cxf_$(cxf_target)_lib): $(cxf_objfiles)
	@$(echo) +++ [$(cxf_target)] Generating static library \'$$(notdir $$@)\'...
	@$(test) $(AR) rcs $$@ $$^

    $(cxf_target): $(CXF_DEPENDS) $(cxf_$(cxf_target)_lib)

    .PHONY: _clean_$(cxf_target)
    _clean_$(cxf_target):
	@echo +++ [$(cxf_target)] Cleaning...
	@$(test) $(RM) $(cxf_objfiles)
	@$(test) $(RM) $(cxf_depfiles)
	@$(test) $(RM) $(cxf_$(cxf_target)_lib)

    clean:: _clean_$(cxf_target)
	@[ -e $(CXFOUT) ] && $(test) rmdir --ignore-fail-on-non-empty $(CXFOUT)
endef


define cxf_build_executable =
    $(eval $(_cxf_import_depfiles))
    $(eval override cxf_program:=$(cxf_testout)/$(1)$(CXFEXE))

    $(cxf_testout): | $(CXFOUT)
	@echo "Creating '$$@'..."
	@$(test) mkdir $$@

    $(cxf_program): $(cxf_objfiles) $(cxf_linkfiles)
	@$(echo) +++ [$(cxf_target)] Generating executable \'$$(notdir $$@)\'...
	@$(test) $(CXX) -o $$@ $$^ $(LDFLAGS) $(CXF_LDFLAGS)

    .PHONY: _build_$(cxf_target)
    _build_$(cxf_target): $(cxf_deptargets) $(cxf_program)

    $(cxf_target): _build_$(cxf_target)

    .PHONY: _clean_$(cxf_target)
    _clean_$(cxf_target):
	@echo +++ [$(cxf_target)] Cleaning...
	@$(test) $(RM) $(cxf_objfiles)
	@$(test) $(RM) $(cxf_depfiles)
	@$(test) $(RM) $(cxf_program)

    clean:: _clean_$(cxf_target)
	@[ -e $(CXFOUT) ] && $(test) rmdir --ignore-fail-on-non-empty $(CXFOUT)
endef


# each release adds another digit of i^i
cxf_version:=0 (beta)
version::
	@echo "( cx-forge, version $(cxf_version) )"
	@echo ""


$(eval $(call cxf_initialize))

endif  # CXF_COMMON_INCLUDE_GUARD
