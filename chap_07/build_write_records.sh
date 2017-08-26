#!/bin/bash

set -u
set -e
set -o pipefail

as --gstabs write-record.s  -o write-record.o
as --gstabs write-records.s -o write-records.o
ld write-record.o write-records.o -o write-records
