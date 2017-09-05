#!/bin/bash

set -u
set -e
set -o pipefail

as --gstabs read-record.s  -o read-record.o
as --gstabs count-chars.s  -o count-chars.o
as --gstabs write-newline.s  -o write-newline.o
as --gstabs read-records.s -o read-records.o
as --gstabs alloc.s -o alloc.o
ld read-record.o \
   count-chars.o \
   write-newline.o \
   read-records.o \
   alloc.o \
   -o read-records
