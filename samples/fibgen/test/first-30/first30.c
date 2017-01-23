// vim: set tabstop=2 softtabstop=2 shiftwidth=2 expandtab :
/*
 * Copyright (c) 2017, Ryan V. Bissell
 * All rights reserved.
 *
 * SPDX-License-Identifier: MIT
 * See the enclosed "LICENSE.forge" file for exact license terms.
 */

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>

#include "fibgen.h"


void usage(char* name)
{
  fprintf(stderr, "USAGE: %s <number>\n", name);
}


int main(int argc, char** argv)
{
  unsigned long n;
  char *endptr;

  if (argc != 3)
  {
    usage(argv[0]);
    exit(EXIT_FAILURE);
  }

  errno = 0;
  n = strtoul(argv[2], &endptr, 10);
  if (errno || *endptr || !*argv[1])
  {
    fprintf(stderr, "Bad number given.\n");
    usage(argv[0]);
    exit(EXIT_FAILURE);
  }

  if (n > 30)
  {
    fprintf(stderr, "I see you gave a number higher than 30.\n"
                    "I also like to live dangerously.\n");
    exit(EXIT_FAILURE);
  }

  fibgen(n);
  exit(EXIT_SUCCESS);
}



