#
# Copyright (c) 2016-2017, Ryan V. Bissell
# All rights reserved.
#
# SPDX-License-Identifier: MIT
# See the enclosed "LICENSE" file for exact license terms.
#

ifndef MF_COMMON_INCLUDE_GUARD
override MF_COMMON_INCLUDE_GUARD:=1

mf_myname:=$(notdir $(lastword $(MAKEFILE_LIST)))
ifndef MFOUT
$(error You must define 'MFOUT' before including $(mf_myname))
endif
$(MFOUT):
	@$(test) mkdir -p $(MFOUT)


.PHONY: clean


# .d files are precious because they serve to speed up subsequent builds.
# .i files are precious because the user specifically asked for them.
.PRECIOUS: $(MFOUT)/%.d $(MFOUT)/%.i


# enable paralellism based on number of available processors
# I believe this is the most portable solution (nearly POSIX)
mf_numprocs=$(shell getconf _NPROCESSORS_ONLN)
override MAKEFLAGS+= --jobs=${mf_numprocs}
ifdef VERBOSE
$(info V: This build will use $(mf_numprocs) processor(s))
endif

# group parallel output on a per-target basis,
# and squelch unhelpful output from Make
# TODO: the --output-sync line will make stderr undetectable by stderred
#override MAKEFLAGS+= --output-sync=target
override MAKEFLAGS+= --no-print-directory



# TODO: these should be specific to the host OS
override MFOBJ:=o
override MFLIB:=a
override MFEXE:=


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

ifdef DEBUG
    override CXXFLAGS+= -ggdb3 -O0
endif

override ECHO:=echo
ifdef MF_QUIET_BUILDS
    override ECHO:=>/dev/null echo
endif


define mf_initialize =
    $(eval override MF_LDFLAGS:=$(LDFLAGS))
    $(eval override MF_CPPFLAGS:=$(CPPFLAGS))
    $(eval override MF_CXXFLAGS:=$(CXXFLAGS))
endef


define mf_declare_target =
    $(eval override mf_target:=$(1))
    $(eval override mf_outdir:=$(MFOUT))
    $(eval override undefine mf_srcfiles)
    $(eval override undefine mf_objfiles)
    $(eval override undefine mf_depfiles)
    $(eval override undefine mf_libfiles)
    $(eval override undefine mf_linkfiles)
    $(eval override undefine mf_deptargets)
endef

define mf_reset_target =
    $(eval $(call mf_initialize))
    $(eval $(call mf_declare_target,$(1)))
endef


define _mf_compile_c++ =
	@$(ECHO) "+++ [$$(notdir $(mf_target))] $$(notdir $$<)"
	@$(test) $(CXX) $(MF_CPPFLAGS) $(MF_CXXFLAGS) -c $$< -o $$@
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
define _mf_gen_dependencies =
	@$(test2) $(CXX) -MM $(MF_CPPFLAGS) $(MF_CXXFLAGS) $$< $(redir)$(mf_outdir)/$(1).d
	@$(test2) mv -f $(mf_outdir)/$(1).d $(mf_outdir)/$(1).d.tmp
	@$(test2) sed -e 's|.*:|$(mf_outdir)/$(1).o:|' $(indir)$(mf_outdir)/$(1).d.tmp $(redir)$(mf_outdir)/$(1).d
	@$(test2) echo "" $(append)$(mf_outdir)/$(1).d
	@$(test2) sed -e 's/.*://' \
	             -e 's/\\$$$$//' $(indir)$(mf_outdir)/$(1).d.tmp $(pipe) \
	 $(test2) fmt -1 $(pipe) \
	 $(test2) sed -e 's/^ *//' \
	             -e 's/$$$$/:\n/' \
	             -e 's/^:.*$$$$/\n/' $(append)$(mf_outdir)/$(1).d
	@$(test2) $(RM) $(mf_outdir)/$(1).d.tmp
endef


define _mf_gen_static_pattern_rule
    $(1): $(mf_outdir)/%.$(MFOBJ): $(2)/%$(3) | $(mf_outdir)
	@$(call _mf_compile_c++)
	@$(call _mf_gen_dependencies,$$*)
endef


define mf_add_sources =
    $(eval override _src:=$(wildcard $(1)/$(2)))
    $(eval override _ext:=$(suffix $(2)))
    $(eval override _obj:=$(subst $(_ext),.$(MFOBJ),$(_src)))
    $(eval override _obj:=$(subst $(1),$(mf_outdir),$(_obj)))
    $(eval override mf_srcfiles+= $(_src))
    $(eval override mf_objfiles+= $(_obj))
    $(eval $(call _mf_gen_static_pattern_rule,$(_obj),$(1),$(_ext)))
    $(eval undefine _src)
    $(eval undefine _ext)
    $(eval undefine _obj)
endef


define mf_lib_dependency =
    $(eval override _lib:=$(mf_$(1)_lib))
    $(eval override mf_deptargets+= $(1))
    $(eval override mf_linkfiles+= $(_lib))
    $(eval undefine _lib)
endef


define _mf_import_depfiles =
    $(eval override mf_depfiles:=$(mf_objfiles:.$(MFOBJ)=.d))
    -include $(mf_depfiles)
endef


define mf_build_static_library =
    $(eval $(_mf_import_depfiles))
    $(eval override mf_$(mf_target)_lib:=$(mf_outdir)/$(1).a)

    $(mf_$(mf_target)_lib): $(mf_objfiles)
	@$(ECHO) +++ [$(mf_target)] Generating static library \'$$(notdir $$@)\'...
	@$(test) $(AR) rcs $$@ $$^

    $(mf_target): $(MF_DEPENDS) $(mf_$(mf_target)_lib)

    .PHONY: _clean_$(mf_target)
    _clean_$(mf_target):
	@$(ECHO) +++ [$(mf_target)] Cleaning...
	@$(test) $(RM) $(mf_objfiles)
	@$(test) $(RM) $(mf_depfiles)
	@$(test) $(RM) $(mf_$(mf_target)_lib)

    clean:: _clean_$(mf_target)
	@[ -e $(MFOUT) ] && $(test) rmdir --ignore-fail-on-non-empty $(MFOUT)
endef


define mf_build_executable =
    $(eval $(_mf_import_depfiles))
    $(eval override mf_program:=$(mf_outdir)/$(1)$(MFEXE))

    $(mf_outdir): | $(MFOUT)
	@$(test) mkdir -p $$@

    $(mf_program): $(mf_objfiles) $(mf_linkfiles)
	@$(ECHO) +++ [$(mf_target)] Generating executable \'$$(notdir $$@)\'...
	@$(test) $(CXX) -o $$@ $$^ $(LDFLAGS) $(MF_LDFLAGS)

    .PHONY: _build_$(mf_target)
    _build_$(mf_target): $(mf_deptargets) $(mf_program)

    $(mf_target): _build_$(mf_target)

    .PHONY: _clean_$(mf_target)
    _clean_$(mf_target):
	@$(ECHO) +++ [$(mf_target)] Cleaning...
	@$(test) $(RM) $(mf_objfiles)
	@$(test) $(RM) $(mf_depfiles)
	@$(test) $(RM) $(mf_program)

    clean:: _clean_$(mf_target)
	@[ -e $(MFOUT) ] && $(test) rmdir --ignore-fail-on-non-empty $(MFOUT)
endef


# each release adds another digit of i^i
mf_version:=0.2 (beta)
version::
	@echo "( cx-forge, version $(mf_version) )"
	@echo ""


$(eval $(call mf_initialize))

endif  # MF_COMMON_INCLUDE_GUARD
