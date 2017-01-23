#
# Copyright (c) 2016-2017, Ryan V. Bissell
# All rights reserved.
#
# SPDX-License-Identifier: BSD-2-Clause
# See the enclosed "LICENSE" file for exact license terms.
#

$(eval $(call tf_use_makeforge,_fibby,$(TF_TESTROOT)/../GNUmakefile.MF))

$(eval $(call tf_declare_test_target,first30))
    override CPPFLAGS:=-I${TF_TESTROOT}/../inc
    $(eval $(call tf_static_dependencies,_fibby@static))
    $(eval $(call tf_add_sources,c,${TF_TESTROOT}/../src,fibgen.c))
    $(eval $(call tf_add_sources,c,${tf_testdir},first30.c))
$(eval $(call tf_build_executable,first30))

$(eval $(call tf_test_md5sum,first30,29d9084943651d6e3f6840f2e2ecebde,30))


