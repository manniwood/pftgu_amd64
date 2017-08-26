#!/bin/bash

set -u
set -e
set -o pipefail

as --gstabs count-chars.s  -o count-chars.o
as --gstabs read-record.s  -o read-record.o
as --gstabs write-record.s  -o write-record.o
as --gstabs write-newline.s  -o write-newline.o
as --gstabs add-year.s  -o add-year.o
as --gstabs error-exit.s  -o error-exit.o
ld read-record.o \
   count-chars.o \
   write-record.o \
   write-newline.o \
   error-exit.o \
   add-year.o \
   -o add-year
