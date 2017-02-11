# vim: set ft=make:
#
# Copyright (c) 2016-2017, Ryan V. Bissell
# All rights reserved.
#
# SPDX-License-Identifier: BSD-2-Clause
# See the enclosed "LICENSE" file for exact license terms.
#

$(call tf-use-makeforge-as,_fibby,$(TF_TESTROOT)/../GNUmakefile.MF)

$(call tf-declare-target,fibseq)
    override CPPFLAGS:=-I${TF_TESTROOT}/../inc
    $(call tf-static-dependencies,_fibby@static)
    $(call tf-add-sources,C,${TF_TESTROOT}/../src,fibgen.c)
    $(call tf-add-sources,C,${tf_testdir},first30.c)
    $(call tf-build-executable)

$(call tf-test-md5sum,fib39,d74e8d3e7dbed0fa4134658a69594231,39)
$(call tf-test-md5sum,fib40,994fb2287a77c89ffd83956a356ba24a,40)
#$(call tf-test-md5sum,fib41,994fb2287a77c89ffd83956a356ba24a,41)



