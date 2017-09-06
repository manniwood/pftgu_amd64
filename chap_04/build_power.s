#!/bin/bash

set -u
set -e
set -o pipefail

# Note that adding --gstabs compiles in useful
# debugging information for gdb.
as --gstabs power.s -o power.o
ld power.o -o power
