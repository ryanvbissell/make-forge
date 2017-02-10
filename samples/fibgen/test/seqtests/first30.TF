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

$(call tf-test-md5sum,first30,29d9084943651d6e3f6840f2e2ecebde,30)


