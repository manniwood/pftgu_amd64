#!/bin/bash

set -u
set -e
set -o pipefail

as --gstabs helloworld-nolib.s  -o helloworld-nolib.o
ld helloworld-nolib.o -o helloworld-nolib
