#!/bin/bash

set -u
set -e
set -o pipefail

# Note that adding --gstabs compiles in useful
# debugging information for gdb.
as --gstabs maximum.s -o maximum.o
ld maximum.o -o maximum
