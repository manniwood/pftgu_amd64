#!/bin/bash

set -u
set -e
set -o pipefail

as --gstabs integer-to-string.s  -o integer-to-string.o
as --gstabs count-chars.s  -o count-chars.o
as --gstabs write-newline.s  -o write-newline.o
as --gstabs conversion-program.s -o conversion-program.o
ld integer-to-string.o \
   count-chars.o \
   write-newline.o \
   conversion-program.o \
   -o conversion-program
