#!/bin/bash

set -u
set -e
set -o pipefail

as maximum.s -o maximum.o
ld maximum.o -o maximum
