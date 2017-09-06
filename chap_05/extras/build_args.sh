#!/bin/bash

set -u
set -e
set -o pipefail

as --gstabs args.s -o args.o
ld args.o -o args
