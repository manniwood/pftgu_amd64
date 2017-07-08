#!/bin/bash

set -u
set -e
set -o pipefail

as -o args.o args.s
ld -o args   args.o
