#!/bin/bash

set -u
set -e
set -o pipefail

as exit.s -o exit.o
ld exit.o -o exit
