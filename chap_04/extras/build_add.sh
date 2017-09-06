#!/bin/bash

set -u
set -e
set -o pipefail

# Note that adding --gstabs compiles in useful
# debugging information for gdb.
as --gstabs add.s -o add.o
ld add.o -o add
