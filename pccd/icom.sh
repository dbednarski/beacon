#!/bin/bash


# Script for "icommands" parameter of daofind
#
# First parameter ($1) is the input file
# Second parameter ($2) is the output file
#
# Bednarski, 14ago16

sed 's/\ \+/\ /g' "$1" | cut -s -d' ' -f2-3 > tmpfile
sed -i '1d' tmpfile
sed 's/$/ 0 a/' tmpfile > "$2"
echo "q" >> "$2"
rm tmpfile
