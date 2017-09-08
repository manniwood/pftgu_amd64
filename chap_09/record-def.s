#
# record-def.s
#
# From p 96 of Programming from the Ground Up, by Jonathan Bartlett
# but translated to amd64

.equ RECORD_FIRSTNAME, 0
.equ RECORD_LASTNAME, 40
.equ RECORD_ADDRESS, 80
.equ RECORD_AGE, 320

# in the book, this is 324, but let's use 4 extra
# bytes so that we can hold a 64-bit int, which is
# the word size anyway.
.equ RECORD_SIZE, 328
