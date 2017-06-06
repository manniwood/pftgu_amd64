#!/bin/bash

set -u
set -e
set -o pipefail

as --gstabs power.s -o power.o
ld power.o -o power
