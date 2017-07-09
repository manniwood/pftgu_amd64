#!/bin/bash

set -u
set -e
set -o pipefail

as --gstabs toupper.s -o toupper.o
ld          -o toupper   toupper.o
