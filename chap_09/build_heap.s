#!/bin/bash

set -u
set -e
set -o pipefail

as heap.s -o heap.o
ld heap.o -o heap
