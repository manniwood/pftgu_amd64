#!/bin/bash

set -u
set -e
set -o pipefail

as --gstabs printf-example.s -o printf-example.o
ld --dynamic-linker /lib64/ld-linux-x86-64.so.2 -o printf-example printf-example.o -lc
# the above ld command inspired by:
# http://stackoverflow.com/questions/15466232/linking-linux-x86-64-assembly-hello-world-program-with-ld-fails

# the same could also be accomplished like so:
# gcc -nostartfiles -m64 -o printf-example printf-example.o
# using gcc instead of ld inspired by
# http://stackoverflow.com/questions/36861903/assembling-32-bit-binaries-on-a-64-bit-system-gnu-toolchain/36901649#36901649
# and
# http://stackoverflow.com/questions/40458869/calling-printf-from-assembly-language-on-64bit-and-32bit-architecture-using-nasm
