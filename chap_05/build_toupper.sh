#!/bin/bash

set -u
set -e
set -o pipefail

as --gstabs toupper.s -o toupper.o
ld toupper.o -o toupper
