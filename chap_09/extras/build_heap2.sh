#!/bin/bash

set -u
set -e
set -o pipefail

as --gstabs heap2.s -o heap2.o
ld          heap2.o -o heap2
