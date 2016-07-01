#
# Copyright (c) 2016, Ryan V. Bissell
# All rights reserved.
#
# SPDX-License-Identifier: MIT
# See the enclosed "LICENSE" file for exact license terms.
#

ifndef MF_INCLUDE_GUARD
override MF_INCLUDE_GUARD:=1

mf_myname:=$(notdir $(lastword $(MAKEFILE_LIST)))

# this must be defined prior
ifndef MF_PROJECT_DIR
$(error You must define 'MF_PROJECT_DIR' before including $(mf_myname))
endif

# superior makefiles need to be able to override this
MFOUT:=$(MF_PROJECT_DIR)/out


.PHONY: clean
.PRECIOUS: $(MFOUT)/%.d $(MFOUT)/%.i


# TODO: these should be specific to the host OS
override MFOBJ:=o
override MFLIB:=a
override MFEXE:=


ifdef TEST
    override test:=echo
    override pipe:=\|
    override redir:=\>
    override indir:=\<
    override append:=\>\>
else
    override test:=
    override pipe:=|
    override redir:=>
    override indir:=<
    override append:=>>
endif


# this will be the default make-target unless you set .DEFAULT_GOAL
.PHONY: help
help:
	$(_mf_display_help)


$(MFOUT):
	@mkdir -p $(MFOUT)


define mf_reset_target =
    $(eval override mf_target:=$(1))
    $(eval override undefine mf_srcfiles)
    $(eval override undefine mf_objfiles)
    $(eval override undefine mf_depfiles)
    $(eval override undefine mf_libfiles)
    $(eval override undefine mf_linkfiles)
    $(eval override undefine mf_deptargets)
    $(eval override MF_LDFLAGS:=$(LDFLAGS))
    $(eval override MF_CPPFLAGS:=$(CPPFLAGS))
    $(eval override MF_CXXFLAGS:=$(CXXFLAGS))
    $(eval override undefine MF_INCLUDES)
endef


define _mf_compile_c++ =
	@echo "+++ [$$(notdir $(mf_target))] $$(notdir $$<)"
	@$(CXX) $(MF_CPPFLAGS) $(MF_INCLUDES) $(MF_CXXFLAGS) -c $$< -o $$@
endef


define _mf_gen_static_pattern_rule
    $(1): $(MFOUT)/%.$(MFOBJ): $(2)/%$(3) | $(MFOUT)
	@$(_mf_compile_c++)
	@$(call _mf_gen_dependencies,$$*)
endef


define mf_add_sources =
    $(eval override _src:=$(wildcard $(1)/$(2)))
    $(eval override _ext:=$(suffix $(2)))
    $(eval override _obj:=$(subst $(_ext),.$(MFOBJ),$(_src)))
    $(eval override _obj:=$(subst $(1),$(MFOUT),$(_obj)))
    $(eval override mf_srcfiles+= $(_src))
    $(eval override mf_objfiles+= $(_obj))
    $(eval $(call _mf_gen_static_pattern_rule,$(_obj),$(1),$(_ext)))
    $(eval undefine _src)
    $(eval undefine _ext)
    $(eval undefine _obj)
endef


define _mf_import_depfiles =
    $(eval override mf_depfiles:=$(mf_objfiles:.$(MFOBJ)=.d))
    -include $(mf_depfiles)
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
	@$(test) $(CXX) -MM $(MF_CPPFLAGS) $(MF_INCLUDES) $(MF_CXXFLAGS) $$< $(redir)$(MFOUT)/$(1).d
	@$(test) mv -f $(MFOUT)/$(1).d $(MFOUT)/$(1).d.tmp
	@$(test) sed -e 's|.*:|$(MFOUT)/$(1).o:|' $(indir)$(MFOUT)/$(1).d.tmp $(redir)$(MFOUT)/$(1).d
	@$(test) echo "" $(append)$(MFOUT)/$(1).d
	@$(test) sed -e 's/.*://' \
	             -e 's/\\$$$$//' $(indir)$(MFOUT)/$(1).d.tmp $(pipe) \
	 $(test) fmt -1 $(pipe) \
	 $(test) sed -e 's/^ *//' \
	             -e 's/$$$$/:\n/' \
	             -e 's/^:.*$$$$/\n/' $(append)$(MFOUT)/$(1).d
	@$(test) $(RM) $(MFOUT)/$(1).d.tmp
endef


define mf_lib_dependency =
    $(eval override _lib:=$(mf_$(1)_lib))
    $(eval override mf_deptargets+= $(1))
    $(eval override mf_linkfiles+= $(_lib))
    $(eval undefine _lib)
endef


define mf_build_static_library =
    $(eval $(_mf_import_depfiles))
    $(eval override mf_$(mf_target)_lib:=$(MFOUT)/$(1).a)

    $(mf_$(mf_target)_lib): $(mf_objfiles)
	@echo +++ [$(mf_target)] Generating static library \'$$(notdir $$@)\'...
	@$(AR) rcs $$@ $$^

    $(mf_target): $(MF_DEPENDS) $(mf_$(mf_target)_lib)

    .PHONY: _clean_$(mf_target)
    _clean_$(mf_target):
	@echo +++ [$(mf_target)] Cleaning...
	@$(RM) $(mf_objfiles)
	@$(RM) $(mf_depfiles)
	@$(RM) $(mf_$(mf_target)_lib)

    clean:: _clean_$(mf_target)
	@[ -e $(MFOUT) ] && rmdir --ignore-fail-on-non-empty $(MFOUT)
endef


define mf_build_executable =
    $(eval $(_mf_import_depfiles))
    $(eval override mf_program:=$(MFOUT)/$(1)$(MFEXE))

    $(mf_program): $(mf_objfiles) $(mf_linkfiles)
	@echo +++ [$(mf_target)] Generating executable \'$$(notdir $$@)\'...
	@$(CXX) -o $$@ $$^ $(LDFLAGS) $(MF_LDFLAGS)

    $(mf_target): $(mf_deptargets) $(mf_program)

    .PHONY: _clean_$(mf_target)
    _clean_$(mf_target):
	@echo +++ [$(mf_target)] Cleaning...
	@$(RM) $(mf_objfiles)
	@$(RM) $(mf_depfiles)
	@$(RM) $(mf_program)

    clean:: _clean_$(mf_target)
	@[ -e $(MFOUT) ] && rmdir --ignore-fail-on-non-empty $(MFOUT)
endef


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


# each release adds another digit of i^i
mf_version:=0 (beta)
version::
	@echo "( make-forge, version $(mf_version) )"
	@echo ""

endif  # MF_INCLUDE_GUARD
