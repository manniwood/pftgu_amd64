#!/bin/bash

set -u
set -e
set -o pipefail

# Note that adding --gstabs compiles in useful
# debugging information for gdb.
as --gstabs factorial.s -o factorial.o
ld factorial.o -o factorial
