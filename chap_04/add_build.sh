#!/bin/bash

set -u
set -e
set -o pipefail

as add.s -o add.o
ld add.o -o add
