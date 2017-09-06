#!/bin/bash

set -u
set -e
set -o pipefail

# Note that adding --gstabs compiles in useful
# debugging information for gdb.
as --gstabs exit.s -o exit.o
ld exit.o -o exit
