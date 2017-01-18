// vim: set tabstop=2 softtabstop=2 shiftwidth=2 expandtab :
/*
 * Copyright (c) 2017, Ryan V. Bissell
 * All rights reserved.
 *
 * SPDX-License-Identifier: MIT
 * See the enclosed "LICENSE.forge" file for exact license terms.
 */

#include <stdio.h>

#include "libfib.h"

void fibgen(uint32_t n)
{
  int i;
  for (i=0; i<n; ++i)
    printf("%i\n", fib(i));
}

