// vim: set tabstop=2 softtabstop=2 shiftwidth=2 expandtab :
/*
 * Copyright (c) 2017, Ryan V. Bissell
 * All rights reserved.
 *
 * SPDX-License-Identifier: MIT
 * See the enclosed "LICENSE.forge" file for exact license terms.
 */

#include "libfib.h"

uint32_t fib(uint32_t n)
{
  switch (n)
  {
    case 0:
    case 1:
      return n;
  }

  return ( fib(n-1) + fib(n-2) );
}



