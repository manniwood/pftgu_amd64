#!/bin/bash

set -u
set -e
set -o pipefail

as --gstabs read-record.s  -o read-record.o
as --gstabs write-record.s  -o write-record.o
as --gstabs add-year.s  -o add-year.o
ld read-record.o \
   write-record.o \
   add-year.o \
   -o add-year
