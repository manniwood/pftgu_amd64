#!/bin/bash

set -u
set -e
set -o pipefail

as --gstabs heap.s -o heap.o
ld          heap.o -o heap
