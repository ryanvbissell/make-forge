#
# Copyright (c) 2016-2017, Ryan V. Bissell
# All rights reserved.
#
# SPDX-License-Identifier: MIT
# See the enclosed "LICENSE.forge" file for exact license terms.
#

ifndef __tf_include_guard
override __tf_include_guard:=1

override _tfname:=$(notdir $(lastword $(MAKEFILE_LIST)))

ifndef TFDIR
    $(error You must define 'TFDIR' before including $(_tfname))
endif
ifndef TF_TESTROOT
    $(error You must define 'TF_TESTROOT' before including $(_tfname))
endif

# remove trailing path separators from these input paths
override TFDIR:=$(TFDIR:%/=%)
override MF_TESTROOT:=$(MF_TESTROOT:%/=%)


override MFOUT:=$(MF_TESTROOT)/.out
override MF_QUIET_BUILDS:=1
override mf_numprocs:=1
include $(TFDIR)/_common-forge


.DEFAULT_GOAL:=all
all:: _all


define tf_register_test =
    $(eval override TF_SUB_TOPDEPS+= ${1})
    $(eval tf_logfile:=$(mf_outdir)/$(mf_target).log)
endef


define _tf_gen_runtarget =
    _announce_$(mf_target):
	@printf '%15s :  ' $(mf_target)

    ${1}: _announce_$(mf_target) _build_$(mf_target)
	@printf 'Running [%-10s]...  ' $(2)
	@$(TF_ENVVARS) $(mf_program) $(mf_outdir) >$(tf_logfile) 2>&1 || (echo "\033[0;31mFAILED with exit status '$$$$?'\033[0m"; exit 1)
endef


define tf_test_exitstatus =
    $(call tf_register_test,${1})
    $(call _tf_gen_runtarget,$(1),exitstatus)
	@echo "PASS"
endef


define tf_test_sha1sum =
    $(call tf_register_test,${1})
    $(call _tf_gen_runtarget,_run_$(1),sha1sum)
    ${1}: _run_$(mf_target)
	@TF_SHA1SUM=`sha1sum $(tf_logfile) | awk '{print $$$$1}'` && \
	 if [ ! "$$$${TF_SHA1SUM}" = "$(2)" ]; then \
	     echo "\033[0;31mFAILED due to sha1 mismatch" ;\
	     echo "$(1): sha1 was '$$$${TF_SHA1SUM}', expected '$(2)'.\033[0m" 2>&1 ;\
	     false ;\
	 else \
	     echo "PASS";\
	     true;\
	 fi
endef


# INTERNAL: initializes internal state
define __tf_initialize =
    $(eval $(call __mf_initialize))
    $(eval override undefine TF_ENVVARS)
endef


# re-initializes, accepts target-name, prepares for target attributes
define tf_declare_target =
    $(eval $(call __tf_initialize))
    $(eval $(call mf_declare_target,$(1)))
    $(eval override mf_outdir:=$(MFOUT)/$(TF_SUB_SECTION)/$(1))

    $(mf_outdir):
	@mkdir -p $(mf_outdir)
endef


define _tf_build_for_test =
    $(eval $(call tf_declare_target,$(1)))
    $(eval $(call mf_add_sources,$(tf_testdir),$(2)))
    $(eval $(call mf_build_executable,$(1)))
endef


# builds executable from a single source file, and tests via exitstatus
define tf_build_and_test_exitstatus =
    $(eval $(call _tf_build_for_test,$(1),$(2)))
    $(call tf_test_exitstatus,${1})
endef


# build executable from a single source file, and tests for sha1sum
define tf_build_and_test_sha1sum =
    $(eval $(call _tf_build_for_test,$(1),$(2)))
    $(call tf_test_sha1sum,$(1),$(3))
endef




tf_topdeps:=
define _tf_include =
    $(eval override TF_SUB_TOPDEPS:=)
    $(eval override TF_SUB_SECTION:=$(2))
    $(eval include ${1})
    $(eval tf_topdeps+= ${TF_SUB_TOPDEPS})
endef


define _tf_include_testdir =
    $(eval override tf_testdir:=$(abspath ${1}))
    $(eval override _tests=$(sort $(wildcard ${1}/[!_]*.mk)))
    $(foreach _test,${_tests},$(call _tf_include,${_test},$(1)))
    $(eval override undefine _test)
    $(eval override undefine _tests)
    $(eval override undefine tf_testdir)
endef


define tf_include_testdirs =
    $(foreach dir,${1},$(call _tf_include_testdir,${dir}))
endef


define tf_import_testdirs =
    tf_subdirs:=$(sort $(wildcard */))
    tf_subdirs:=$(patsubst %/,%,$(tf_subdirs))
    $(info === Importing tests ...)
    $(eval $(call tf_include_testdirs,$(tf_subdirs)))

    all: $(tf_topdeps)
endef


endif  # __tf_include_guard
