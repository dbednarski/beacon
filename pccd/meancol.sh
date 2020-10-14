#!/bin/bash
#
#
# Script to compute the mean of columns 3, 4 and 5
# of output daoedit file (SKY, SKYSIGMA, FWHM).
# The output file have these 3 values computed, one by line
#
# First parameter ($1) is the input file
# Second parameter ($2) is the output file
#
#
# Depends on *bc* (sudo apt-get install bc)
#
#
# Bednarski, 2020/09/30
#


if [ -f "$2" ]; then
    rm "$2"
fi
    
# Loop on columns
for col in {3..5}; do

    sum=""
    n=0
    # Loop on rows
    while read line; do
        num=$(echo "$line" | grep -e [0-9] | tr -s ' ' | cut -d' ' -f"$col");
        if [[ $num != "" ]]; then
            sum="$num + $sum"
            n=$((n+1))
        fi
    done < "$1"
    
    # Compute, using bc command.
    # $sum 0 is because there is a last "+" sign in $sum.
    # scale=3 makes the result be %.3f
    if [ $n == 0 ]; then
        echo "ERROR [meancol.sh]: impossible to perform division by 0. Check the file $1." 
        exit 1
    fi
    echo "scale=3; ($sum 0)/$n" | bc >> "$2"

done


#echo \("$sum" 0\)/"$n" | bc -l > "$3"

exit 0
