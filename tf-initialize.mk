#
# Copyright (c) 2016, Ryan V. Bissell
# All rights reserved.
#
# SPDX-License-Identifier: BSD-2-Clause
# See the enclosed "LICENSE" file for exact license terms.
#

ifndef TF_INCLUDE_GUARD
override TF_INCLUDE_GUARD:=1

# remove trailing path separators from these input paths
override CXFDIR:=$(patsubst %/,%,$(CXFDIR))
override CXF_TESTROOT:=$(patsubst %/,%,$(CXF_TESTROOT))

override CXF_QUIET_BUILDS:=1
override CXFOUT:=$(CXF_TESTROOT)/.out
include $(CXFDIR)/_cxf-common.mk


.PHONY: _phony

.DEFAULT_GOAL:=all
all: _all


define tf_register_test =
    $(eval override TF_SUB_TOPDEPS+= ${1})
    $(eval tf_logfile:=$(cxf_testout)/$(cxf_target).log)
endef


define _tf_gen_runtarget =
    ${1}: _build_$(cxf_target)
	@echo "Running [$(2)]:  '$(cxf_target)' ..."
	@$(cxf_program) >$(tf_logfile) 2>&1
endef


define tf_test_exitstatus =
    $(call tf_register_test,${1})
    $(call _tf_gen_runtarget,$(1),exitstatus)
endef


define tf_test_sha1sum =
    $(call tf_register_test,${1})
    $(call _tf_gen_runtarget,_run_$(1),sha1sum   )
    ${1}: _run_$(cxf_target)
	@TF_SHA1SUM=`sha1sum $(tf_logfile) | awk '{print $$$$1}'` && \
	 if [ ! "$$$${TF_SHA1SUM}" = "$(2)" ]; then \
	     echo "$(1): sha1 was '$$$${TF_SHA1SUM}', expected '$(2)'." 2>&1 ;\
	     false ;\
	 fi
endef


define _tf_build_for_test =
    $(eval $(call cxf_declare_target,$(1),$(TF_SUB_SECTION)))
    $(eval $(call cxf_add_sources,$(tf_testdir),$(2)))
    $(eval $(call cxf_build_executable,$(1)))
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


endif  # TF_INCLUDE_GUARD
