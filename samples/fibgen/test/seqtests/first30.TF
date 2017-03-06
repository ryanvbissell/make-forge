# vim: set ft=make:
#
# Copyright (c) 2016-2017, Ryan V. Bissell
# All rights reserved.
#
# SPDX-License-Identifier: BSD-2-Clause
# See the enclosed "LICENSE" file for exact license terms.
#

$(call tf-export-makeforge-as,exported-fibby,$(TF_TESTROOT)/../GNUmakefile.MF)

$(call tf-declare-target,FIBSEQ)
    override CPPFLAGS:=-I${TF_TESTROOT}/../inc
    $(call tf-static-dependencies,static@exported-fibby)
    $(call tf-add-sources,C,${TF_TESTROOT}/../src,fibgen.c)
    $(call tf-add-sources,C,${TF_TESTDIR},first30.c)
    $(call tf-build-executable)

$(call tf-test-exitstatus,fib21,21)
$(call tf-test-md5sum,fib39,d74e8d3e7dbed0fa4134658a69594231,39)
$(call tf-test-md5sum,fib40,994fb2287a77c89ffd83956a356ba24a,40)

# this one intentionally fails
#$(call tf-test-exitstatus,fib41,41)



